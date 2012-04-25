//
//  HLSSlideshow.m
//  CoconutKit
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSSlideshow.h"

#import "HLSAssert.h"
#import "HLSFloat.h"
#import "HLSLogger.h"
#import "UIImage+HLSExtensions.h"
#import "UIView+HLSExtensions.h"

static const NSTimeInterval kSlideshowDefaultImageDuration = 4.;
static const NSTimeInterval kSlideshowDefaultTransitionDuration = 3.;
static const CGFloat kKenBurnsSlideshowMaxScaleFactorDelta = 0.4f;

static const NSInteger kSlideshowNoIndex = -1;

@interface HLSSlideshow () <HLSAnimationDelegate>

- (void)hlsSlideshowInit;

@property (nonatomic, retain) NSArray *imageViews;
@property (nonatomic, retain) HLSAnimation *animation;

- (UIImage *)imageForNameOrPath:(NSString *)imageNameOrPath;
- (void)prepareImageView:(UIImageView *)imageView withImageNameOrPath:(NSString *)imageNameOrPath;
- (void)releaseImageView:(UIImageView *)imageView;
- (NSString *)imageNameOrPathForImageView:(UIImageView *)imageView;

- (HLSAnimation *)crossDissolveAnimationWithCurrentImageView:(UIImageView *)currentImageView
                                               nextImageView:(UIImageView *)nextImageView
                                          transitionDuration:(NSTimeInterval)transitionDuration;
- (HLSAnimation *)kenBurnsAnimationWithCurrentImageView:(UIImageView *)currentImageView
                                          nextImageView:(UIImageView *)nextImageView;
- (HLSAnimation *)animationForEffect:(HLSSlideshowEffect)effect
                    currentImageView:(UIImageView *)currentImageView
                       nextImageView:(UIImageView *)nextImageView;
- (HLSAnimation *)translationAnimationWithCurrentImageView:(UIImageView *)currentImageView
                                             nextImageView:(UIImageView *)nextImageView
                                                   xOffset:(CGFloat)xOffset
                                                   yOffset:(CGFloat)yOffset;

- (void)playNextAnimation;
- (void)playAnimationForImageWithNameOrPath:(NSString *)imageNameOrPath;
- (void)playAnimationForNextImage;
- (void)playAnimationForPreviousImage;
- (void)animateImages;

- (NSUInteger)randomIndexWithUpperBound:(NSUInteger)upperBound forbiddenIndex:(NSInteger)forbiddenIndex;

@end

@implementation HLSSlideshow

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self hlsSlideshowInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self hlsSlideshowInit];
    }
    return self;
}

- (void)hlsSlideshowInit
{
    self.clipsToBounds = YES;           // Uncomment this line to better see what is happening when debugging
    
    m_currentImageIndex = kSlideshowNoIndex;
    
    self.imageViews = [NSArray array];
    for (NSUInteger i = 0; i < 2; ++i) {
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:imageView];
        
        self.imageViews = [self.imageViews arrayByAddingObject:imageView];
    }
    
    self.imageDuration = kSlideshowDefaultImageDuration;
    self.transitionDuration = kSlideshowDefaultTransitionDuration;
    self.random = NO;
}

- (void)dealloc
{
    [self stop];
    
    self.imageViews = nil;
    self.imageNamesOrPaths = nil;
    self.animation = nil;
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize effect = m_effect;

- (void)setEffect:(HLSSlideshowEffect)effect
{
    if (self.animation.running) {
        HLSLoggerWarn(@"The effect cannot be changed while the slideshow is running");
        return;
    }
    
    m_effect = effect;
}

@synthesize imageViews = m_imageViews;

@synthesize imageNamesOrPaths = m_imageNamesOrPaths;

- (void)setImageNamesOrPaths:(NSArray *)imageNamesOrPaths
{   
    HLSAssertObjectsInEnumerationAreKindOfClass(imageNamesOrPaths, NSString);
    
    if (m_imageNamesOrPaths == imageNamesOrPaths) {
        return;
    }
    
    if ([imageNamesOrPaths count] != 0) {
        if (m_currentImageIndex != kSlideshowNoIndex) {
            // Try to find whether the current image is also in the new array. If the answer is
            // yes, start at the corresponding location to guarantee we won't see the same image
            // soon afterwards (if images are not displayed randomly, of course)
            NSString *currentImageNameOrPath = [m_imageNamesOrPaths objectAtIndex:m_currentImageIndex];
            NSUInteger currentImageIndexInNewArray = [imageNamesOrPaths indexOfObject:currentImageNameOrPath];
            if (currentImageIndexInNewArray != NSNotFound) {
                m_currentImageIndex = currentImageIndexInNewArray;
            }
            // Otherwise start at the beginning
            else {
                m_currentImageIndex = kSlideshowNoIndex;
            }
        }        
    }
    else {
        [self stop];
    }
    
    [m_imageNamesOrPaths release];
    m_imageNamesOrPaths = [imageNamesOrPaths retain];
}

@synthesize animation = m_animation;

@synthesize imageDuration = m_imageDuration;

- (void)setImageDuration:(NSTimeInterval)imageDuration
{
    if (doublele(imageDuration, 0.)) {
        HLSLoggerWarn(@"Image duration must be > 0; fixed to default value");
        imageDuration = kSlideshowDefaultImageDuration;
    }
    
    m_imageDuration = imageDuration;
}

@synthesize transitionDuration = m_transitionDuration;

- (void)setTransitionDuration:(NSTimeInterval)transitionDuration
{
    if (doublelt(transitionDuration, 0.)) {
        HLSLoggerWarn(@"Transition duration must be >= 0; fixed to 0");
        transitionDuration = 0.;
    }
    
    m_transitionDuration = transitionDuration;
}

@synthesize random = m_random;

- (BOOL)isRunning
{
    return self.animation.running;
}

@synthesize delegate = m_delegate;

#pragma mark Playing the slideshow

- (void)play
{
    if (self.animation.running) {
        HLSLoggerWarn(@"The slideshow is already running");
        return;
    }
    
    if ([self.imageNamesOrPaths count] == 0) {
        HLSLoggerInfo(@"No images to display. Nothing to animate");
        return;
    }
    
    m_currentImageIndex = kSlideshowNoIndex;
    m_nextImageIndex = kSlideshowNoIndex;
    m_currentImageViewIndex = kSlideshowNoIndex;
    
    [self playAnimationForNextImage];
}

- (void)stop
{
    if (! self.animation.running) {
        HLSLoggerInfo(@"The slideshow is not running");
        return;
    }    
    
    [self.animation cancel];
    self.animation = nil;
    
    m_currentImageIndex = kSlideshowNoIndex;
    m_nextImageIndex = kSlideshowNoIndex;
    m_currentImageViewIndex = kSlideshowNoIndex;
    
    for (UIImageView *imageView in self.imageViews) {
        imageView.image = nil;
    }
}

- (void)skipToNextImage
{
    if (! self.animation.running) {
        return;
    }
    
    [self.animation terminate];
    for (UIImageView *imageView in self.imageViews) {
        [self releaseImageView:imageView];
    }
    [self playAnimationForNextImage];
}

- (void)skipToPreviousImage
{
    if (! self.animation.running) {
        return;
    }
    
    [self.animation terminate];
    for (UIImageView *imageView in self.imageViews) {
        [self releaseImageView:imageView];
    }
    [self playAnimationForPreviousImage];
}

- (void)skipToImageWithNameOrPath:(NSString *)imageNameOrPath
{
    if (! self.animation.running) {
        return;
    }
    
    NSUInteger imageIndex = [self.imageNamesOrPaths indexOfObject:imageNameOrPath];
    if (imageIndex == NSNotFound) {
        HLSLoggerWarn(@"The image %@ does not appear in the slideshow image list", imageNameOrPath);
        return;
    }
    
    [self.animation terminate];
    for (UIImageView *imageView in self.imageViews) {
        [self releaseImageView:imageView];
    }
    [self playAnimationForImageWithNameOrPath:imageNameOrPath];
}

- (NSString *)currentImageNameOrPath
{
    if (m_currentImageViewIndex == kSlideshowNoIndex) {
        return nil;
    }
    
    if ([self.animation isRunning]) {
        UIImageView *currentImageView = [self.imageViews objectAtIndex:m_currentImageViewIndex];
        return [self imageNameOrPathForImageView:currentImageView];        
    }
    else {
        UIImageView *nextImageView = [self.imageViews objectAtIndex:(m_currentImageViewIndex + 1) % 2];
        return [self imageNameOrPathForImageView:nextImageView];
    }
}

#pragma mark Image management

// Return the image corresponding to a name or path. If the image is not found, return a dummy invisible image
- (UIImage *)imageForNameOrPath:(NSString *)imageNameOrPath
{
    UIImage *image = [UIImage imageNamed:imageNameOrPath];
    if (! image) {
        image = [UIImage imageWithContentsOfFile:imageNameOrPath];
    }
    if (! image) {
        HLSLoggerWarn(@"Missing image %@", imageNameOrPath);
        image = [UIImage imageWithColor:[UIColor clearColor]];
    }
    return image;
}

// Setup an image view to display a given image. The image view frame is adjusted to get an aspect fill / aspect fit
// behavior for the image view, and is centered in self. The view alpha is reset to 1
- (void)prepareImageView:(UIImageView *)imageView withImageNameOrPath:(NSString *)imageNameOrPath
{
    UIImage *image = [self imageForNameOrPath:imageNameOrPath];
    
    // Calculate the scale which needs to be applied to get aspect fill behavior for the image view
    // TODO: This code is quite common (most notably in PDF generator code). Factor it somewhere where it can easily
    //       be reused
    CGFloat zoomScale;
    // Aspect ratios of frame and image
    CGFloat frameRatio = CGRectGetWidth(self.frame) / CGRectGetHeight(self.frame);
    CGFloat imageRatio = image.size.width / image.size.height;
    if (self.effect == HLSSlideshowEffectNone || self.effect == HLSSlideshowEffectCrossDissolve) {
        // The image is more portrait-shaped than self
        if (floatlt(imageRatio, frameRatio)) {
            zoomScale = CGRectGetHeight(self.frame) / image.size.height;
        }
        // The image is more landscape-shaped than self
        else {
            zoomScale = CGRectGetWidth(self.frame) / image.size.width;
        }
    }
    // Calculate the scale which needs to be applied to get aspect fit behavior for the image view
    else {
        // The image is more portrait-shaped than self
        if (floatlt(imageRatio, frameRatio)) {
            zoomScale = CGRectGetWidth(self.frame) / image.size.width;
        }
        // The image is more landscape-shaped than self
        else {
            zoomScale = CGRectGetHeight(self.frame) / image.size.height;
        }
    }
    
    // Update the image view to match the image dimensions with an aspect fill behavior inside self
    CGFloat scaledImageWidth = ceilf(image.size.width * zoomScale);
    CGFloat scaledImageHeight = ceilf(image.size.height * zoomScale);
    imageView.bounds = CGRectMake(0.f, 0.f, scaledImageWidth, scaledImageHeight);
    imageView.center = CGPointMake(floorf(CGRectGetWidth(self.frame) / 2.f), floorf(CGRectGetHeight(self.frame) / 2.f));
    imageView.layer.transform = CATransform3DIdentity;
    imageView.alpha = 1.f;
    imageView.image = image;
    imageView.userInfo_hls = [NSDictionary dictionaryWithObject:imageNameOrPath forKey:@"imageNameOrPath"];
}

- (void)releaseImageView:(UIImageView *)imageView
{
    // Mark the image view as unused by removing the attached image
    imageView.image = nil;
    imageView.userInfo_hls = nil;
    imageView.layer.transform = CATransform3DIdentity;
}

- (NSString *)imageNameOrPathForImageView:(UIImageView *)imageView
{
    return [[imageView userInfo_hls] objectForKey:@"imageNameOrPath"];
}

// Randomly move and scale an image view so that it stays in self.view. Returns random scale factors, x and y offsets
// which can be applied to reach a new random valid state
- (void)randomlyMoveAndScaleImageView:(UIImageView *)imageView
                          scaleFactor:(CGFloat *)pScaleFactor
                              xOffset:(CGFloat *)pXOffset
                              yOffset:(CGFloat *)pYOffset
{
    // Pick up a random initial scale factor. Must be >= 1, and not too large. Use random factor in [0;1]
    CGFloat scaleFactor = 1.f + kKenBurnsSlideshowMaxScaleFactorDelta * (arc4random() % 1001) / 1000.f;
    
    // The image is centered in the image view. Calculate the maximum translation offsets we can apply for the selected
    // scale factor so that the image view still covers self
    CGFloat maxXOffset = (scaleFactor * CGRectGetWidth(imageView.frame) - CGRectGetWidth(self.frame)) / 2.f;
    CGFloat maxYOffset = (scaleFactor * CGRectGetHeight(imageView.frame) - CGRectGetHeight(self.frame)) / 2.f;
    
    // Pick up some random offsets. Use random factor in [-1;1]
    CGFloat xOffset = 2 * ((arc4random() % 1001) / 1000.f - 0.5f) * maxXOffset;
    CGFloat yOffset = 2 * ((arc4random() % 1001) / 1000.f - 0.5f) * maxYOffset;
    
    // Pick up random scale factor to reach at the end of the animation. Same constraints as above
    CGFloat finalScaleFactor = 1.f + kKenBurnsSlideshowMaxScaleFactorDelta * (arc4random() % 1001) / 1000.f;
    CGFloat maxFinalXOffset = (finalScaleFactor * CGRectGetWidth(imageView.frame) - CGRectGetWidth(self.frame)) / 2.f;
    CGFloat maxFinalYOffset = (finalScaleFactor * CGRectGetHeight(imageView.frame) - CGRectGetHeight(self.frame)) / 2.f;
    CGFloat finalXOffset = 2 * ((arc4random() % 1001) / 1000.f - 0.5f) * maxFinalXOffset;
    CGFloat finalYOffset = 2 * ((arc4random() % 1001) / 1000.f - 0.5f) * maxFinalYOffset;
    
    // Apply initial transform to set initial image view position
    imageView.layer.transform = CATransform3DConcat(CATransform3DMakeScale(scaleFactor, scaleFactor, 1.f),
                                                    CATransform3DMakeTranslation(xOffset, yOffset, 0.f));
    
    if (pScaleFactor) {
        *pScaleFactor = finalScaleFactor / scaleFactor;
    }
    if (pXOffset) {
        *pXOffset = finalXOffset - xOffset;
    }
    if (pYOffset) {
        *pYOffset = finalYOffset - yOffset;
    }
}

#pragma mark Animations

- (HLSAnimation *)crossDissolveAnimationWithCurrentImageView:(UIImageView *)currentImageView
                                               nextImageView:(UIImageView *)nextImageView
                                          transitionDuration:(NSTimeInterval)transitionDuration
{
    // Initially hide the next image
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    animationStep1.duration = 0.;
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = -1.f;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:nextImageView];
    
    // Display the current image for the duration which has been set
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    animationStep2.tag = @"singleImage";
    animationStep2.duration = self.imageDuration;
    
    // Transition to the next image
    HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStep];
    animationStep3.duration = transitionDuration;
    HLSViewAnimationStep *viewAnimationStep31 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep31.alphaVariation = -1.f;
    [animationStep3 addViewAnimationStep:viewAnimationStep31 forView:currentImageView];
    HLSViewAnimationStep *viewAnimationStep32 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep32.alphaVariation = 1.f;
    [animationStep3 addViewAnimationStep:viewAnimationStep32 forView:nextImageView];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithObjects:animationStep1, animationStep2, animationStep3, nil]];
}

- (HLSAnimation *)kenBurnsAnimationWithCurrentImageView:(UIImageView *)currentImageView
                                          nextImageView:(UIImageView *)nextImageView
{
    // To understand how to calculate the scale factor for each step, divide the total time interval in N equal intervals.
    // To get a smooth scale animation with total factor scaleFactor, each interval must be assigned a factor (scaleFactor)^(1/N),
    // so that the total scaleFactor is obtained by multiplying all of them. When grouping m such intervals, the scale factor
    // for the m intervals is therefore (scaleFactor)^(m/N), thus the formula for the scale factor of each step.
    
    CGFloat totalDuration = self.imageDuration + 2 * self.transitionDuration;
    
    CGFloat currentImageScaleFactor = 0.f;
    CGFloat currentImageXOffset = 0.f;
    CGFloat currentImageYOffset = 0.f;
    NSDictionary *userInfo = self.animation.userInfo;
    
    HLSAnimationStep *animationStep0 = [HLSAnimationStep animationStep];
    animationStep0.duration = 0.;
    HLSViewAnimationStep *viewAnimationStep01 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep01.alphaVariation = -1.f;
    [animationStep0 addViewAnimationStep:viewAnimationStep01 forView:nextImageView];
    
    // User information attached: Not the first animation loop (and not reset after skipping
    // to the next or previous image)
    if ([userInfo objectForKey:@"scaleFactor"] && ! self.animation.terminating) {
        currentImageScaleFactor = [[userInfo objectForKey:@"scaleFactor"] floatValue];
        currentImageXOffset = [[userInfo objectForKey:@"xOffset"] floatValue];
        currentImageYOffset = [[userInfo objectForKey:@"yOffset"] floatValue];
    }
    // No user information attached: First animation loop
    else {
        [self randomlyMoveAndScaleImageView:currentImageView 
                                scaleFactor:&currentImageScaleFactor
                                    xOffset:&currentImageXOffset 
                                    yOffset:&currentImageYOffset];
        
        HLSViewAnimationStep *viewAnimationStep02 = [HLSViewAnimationStep viewAnimationStep];
        CGFloat scaleFactor02 = powf(currentImageScaleFactor, self.transitionDuration / totalDuration);
        CGFloat xOffset02 = currentImageXOffset * self.transitionDuration / totalDuration;
        CGFloat yOffset02 = currentImageYOffset * self.transitionDuration / totalDuration;
        viewAnimationStep02.transform = CATransform3DConcat(CATransform3DMakeScale(scaleFactor02, scaleFactor02, 1.f),
                                                            CATransform3DMakeTranslation(xOffset02, yOffset02, 0.f));
        [animationStep0 addViewAnimationStep:viewAnimationStep02 forView:currentImageView];
    }
    
    CGFloat nextImageScaleFactor = 0.f;
    CGFloat nextImageXOffset = 0.f;
    CGFloat nextImageYOffset = 0.f;
    [self randomlyMoveAndScaleImageView:nextImageView 
                            scaleFactor:&nextImageScaleFactor 
                                xOffset:&nextImageXOffset 
                                yOffset:&nextImageYOffset];
    
    // Displaying the current image
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    animationStep1.tag = @"singleImage";
    animationStep1.curve = UIViewAnimationCurveLinear;         // Linear for smooth transition between steps
    animationStep1.duration = self.imageDuration;
    
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    CGFloat scaleFactor11 = powf(currentImageScaleFactor, self.imageDuration / totalDuration);
    CGFloat xOffset11 = currentImageXOffset * self.imageDuration / totalDuration;
    CGFloat yOffset11 = currentImageYOffset * self.imageDuration / totalDuration;
    viewAnimationStep11.transform = CATransform3DConcat(CATransform3DMakeScale(scaleFactor11, scaleFactor11, 1.f),
                                                        CATransform3DMakeTranslation(xOffset11, yOffset11, 0.f));
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:currentImageView];
    
    // Transition
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    animationStep2.curve = UIViewAnimationCurveLinear;
    animationStep2.duration = self.transitionDuration;
    
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    CGFloat scaleFactor21 = powf(currentImageScaleFactor, self.transitionDuration / totalDuration);
    CGFloat xOffset21 = currentImageXOffset * self.transitionDuration / totalDuration;
    CGFloat yOffset21 = currentImageYOffset * self.transitionDuration / totalDuration;
    viewAnimationStep21.transform = CATransform3DConcat(CATransform3DMakeScale(scaleFactor21, scaleFactor21, 1.f),
                                                        CATransform3DMakeTranslation(xOffset21, yOffset21, 0.f));
    viewAnimationStep21.alphaVariation = -1.f;
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:currentImageView];
    
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    CGFloat scaleFactor22 = powf(nextImageScaleFactor, self.transitionDuration / totalDuration);
    CGFloat xOffset22 = nextImageXOffset * self.transitionDuration / totalDuration;
    CGFloat yOffset22 = nextImageYOffset * self.transitionDuration / totalDuration;
    viewAnimationStep22.transform = CATransform3DConcat(CATransform3DMakeScale(scaleFactor22, scaleFactor22, 1.f),
                                                        CATransform3DMakeTranslation(xOffset22, yOffset22, 0.f));
    viewAnimationStep22.alphaVariation = 1.f;
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:nextImageView];
    
    HLSAnimation *animation = [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithObjects:animationStep0,
                                                                         animationStep1,
                                                                         animationStep2,
                                                                         nil]];
    animation.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:nextImageScaleFactor], @"scaleFactor",
                          [NSNumber numberWithFloat:nextImageXOffset], @"xOffset", 
                          [NSNumber numberWithFloat:nextImageYOffset], @"yOffset",
                          nil];
    return animation;
}

- (HLSAnimation *)translationAnimationWithCurrentImageView:(UIImageView *)currentImageView
                                             nextImageView:(UIImageView *)nextImageView
                                                   xOffset:(CGFloat)xOffset
                                                   yOffset:(CGFloat)yOffset
{
    // Move the next image to its initial position
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    animationStep1.duration = 0.;
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.transform = CATransform3DMakeTranslation(xOffset, yOffset, 0.f);
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:nextImageView];
    
    // Display the current image for the duration which has been set (identity view animation step)
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    animationStep2.tag = @"singleImage";
    animationStep2.duration = self.imageDuration;
    
    // Transition to the next image
    HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStep];
    animationStep3.duration = self.transitionDuration;
    HLSViewAnimationStep *viewAnimationStep31 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep31.transform = CATransform3DMakeTranslation(-xOffset, -yOffset, 0.f);
    [animationStep3 addViewAnimationStep:viewAnimationStep31 forView:currentImageView];
    HLSViewAnimationStep *viewAnimationStep32 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep32.transform = CATransform3DMakeTranslation(-xOffset, -yOffset, 0.f);
    [animationStep3 addViewAnimationStep:viewAnimationStep32 forView:nextImageView];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithObjects:animationStep1, animationStep2, animationStep3, nil]];
}

- (HLSAnimation *)animationForEffect:(HLSSlideshowEffect)effect
                    currentImageView:(UIImageView *)currentImageView
                       nextImageView:(UIImageView *)nextImageView
{
    HLSAnimation *animation = nil;
    switch (effect) {
        case HLSSlideshowEffectNone: {
            animation = [self crossDissolveAnimationWithCurrentImageView:currentImageView
                                                           nextImageView:nextImageView 
                                                      transitionDuration:0.];
            break;
        }
            
        case HLSSlideshowEffectCrossDissolve: {
            animation = [self crossDissolveAnimationWithCurrentImageView:currentImageView
                                                           nextImageView:nextImageView
                                                      transitionDuration:self.transitionDuration];
            break;
        }
            
        case HLSSlideshowEffectKenBurns: {
            animation = [self kenBurnsAnimationWithCurrentImageView:currentImageView
                                                      nextImageView:nextImageView];
            break;
        }
            
        case HLSSlideshowEffectHorizontalRibbon: {
            animation = [self translationAnimationWithCurrentImageView:currentImageView 
                                                         nextImageView:nextImageView 
                                                               xOffset:(CGRectGetWidth(currentImageView.frame) + CGRectGetWidth(nextImageView.frame)) / 2.f
                                                               yOffset:0.f];
            break;
        }
            
        case HLSSlideshowEffectInverseHorizontalRibbon: {
            animation = [self translationAnimationWithCurrentImageView:currentImageView 
                                                         nextImageView:nextImageView 
                                                               xOffset:-(CGRectGetWidth(currentImageView.frame) + CGRectGetWidth(nextImageView.frame)) / 2.f
                                                               yOffset:0.f];
            break;
        }
            
        case HLSSlideshowEffectVerticalRibbon: {
            animation = [self translationAnimationWithCurrentImageView:currentImageView 
                                                         nextImageView:nextImageView 
                                                               xOffset:0.f
                                                               yOffset:(CGRectGetHeight(currentImageView.frame) + CGRectGetHeight(nextImageView.frame)) / 2.f];
            break;
        }
            
        case HLSSlideshowEffectInverseVerticalRibbon: {
            animation = [self translationAnimationWithCurrentImageView:currentImageView 
                                                         nextImageView:nextImageView 
                                                               xOffset:0.f
                                                               yOffset:-(CGRectGetHeight(currentImageView.frame) + CGRectGetHeight(nextImageView.frame)) / 2.f];
            break;
        }
            
        default: {
            HLSLoggerError(@"Unkown effect");
            return nil;
            break;
        }
    }
    animation.delegate = self;
    return animation;
}

- (void)playNextAnimation
{
    NSUInteger numberOfImages = [self.imageNamesOrPaths count];
    NSAssert(numberOfImages != 0, @"Cannot be called when no images have been loaded");
    
    if (self.random) {
        if (numberOfImages > 1) {
            // Avoid displaying the same image twice in a row
            m_currentImageIndex = m_nextImageIndex;
            m_nextImageIndex = [self randomIndexWithUpperBound:numberOfImages forbiddenIndex:m_currentImageIndex];
        }
        else {
            m_currentImageIndex = 0;
            m_nextImageIndex = 0;
        }
    }
    else {
        m_currentImageIndex = (m_currentImageIndex + 1) % numberOfImages;
        m_nextImageIndex = (m_currentImageIndex + 1) % numberOfImages;
    }
    
    [self animateImages];
}

- (void)playAnimationForImageWithNameOrPath:(NSString *)imageNameOrPath
{
    NSUInteger numberOfImages = [self.imageNamesOrPaths count];
    NSAssert(numberOfImages != 0, @"Cannot be called when no images have been loaded");
    
    NSUInteger imageIndex = [self.imageNamesOrPaths indexOfObject:imageNameOrPath];
    if (imageIndex == NSNotFound) {
        HLSLoggerWarn(@"The image %@ does not appear in the slideshow image list", imageNameOrPath);
        return;
    }
    
    m_currentImageIndex = imageIndex;
    
    if (self.random) {
        if (numberOfImages > 1) {
            // Avoid displaying the same image twice in a row
            m_nextImageIndex = [self randomIndexWithUpperBound:numberOfImages forbiddenIndex:m_currentImageIndex];
        }
        else {
            NSAssert(imageIndex == 0, @"Only one image, must have index 0");
            m_nextImageIndex = 0;
        }
    }
    else {
        m_nextImageIndex = (m_currentImageIndex + 1) % numberOfImages;
    }
    
    [self animateImages];
}

- (void)playAnimationForNextImage
{
    NSUInteger numberOfImages = [self.imageNamesOrPaths count];
    NSAssert(numberOfImages != 0, @"Cannot be called when no images have been loaded");
    
    if (self.random) {
        if (numberOfImages > 1) {
            // Avoid displaying the same image twice in a row
            m_currentImageIndex = [self randomIndexWithUpperBound:numberOfImages forbiddenIndex:m_currentImageIndex];
            m_nextImageIndex = [self randomIndexWithUpperBound:numberOfImages forbiddenIndex:m_currentImageIndex];
        }
        else {
            m_currentImageIndex = 0;
            m_nextImageIndex = 0;
        }
    }
    else {
        m_currentImageIndex = (m_currentImageIndex + 1) % numberOfImages;
        m_nextImageIndex = (m_currentImageIndex + 1) % numberOfImages;
    }
    
    [self animateImages];
}

- (void)playAnimationForPreviousImage
{
    NSUInteger numberOfImages = [self.imageNamesOrPaths count];
    NSAssert(numberOfImages != 0, @"Cannot be called when no images have been loaded");
    
    if (self.random) {
        if (numberOfImages > 1) {
            // Avoid displaying the same image twice in a row
            m_currentImageIndex = [self randomIndexWithUpperBound:numberOfImages forbiddenIndex:m_currentImageIndex];
            m_nextImageIndex = [self randomIndexWithUpperBound:numberOfImages forbiddenIndex:m_currentImageIndex];
        }
        else {
            m_currentImageIndex = 0;
            m_nextImageIndex = 0;
        }
    }
    else {
        // Add numberOfImages to avoid issues when crossing 0
        m_currentImageIndex = (m_currentImageIndex - 1 + numberOfImages) % numberOfImages;
        m_nextImageIndex = (m_currentImageIndex - 1 + numberOfImages) % numberOfImages;
    }
    
    [self animateImages];
}

- (void)animateImages
{    
    // Find the image views to use for the current / next images. Only unused image views (i.e. with image == nil)
    // have to be filled at each step.
    m_currentImageViewIndex = (m_currentImageViewIndex + 1) % 2;
    UIImageView *currentImageView = [self.imageViews objectAtIndex:m_currentImageViewIndex];
    if (! currentImageView.image) {
        NSString *currentImagePath = [self.imageNamesOrPaths objectAtIndex:m_currentImageIndex];
        [self prepareImageView:currentImageView withImageNameOrPath:currentImagePath];
    }
    
    UIImageView *nextImageView = [self.imageViews objectAtIndex:(m_currentImageViewIndex + 1) % 2];
    if (! nextImageView.image) {
        NSString *nextImagePath = [self.imageNamesOrPaths objectAtIndex:m_nextImageIndex];
        [self prepareImageView:nextImageView withImageNameOrPath:nextImagePath];
    }
    
    // Create and play the animation
    self.animation = [self animationForEffect:self.effect
                             currentImageView:currentImageView
                                nextImageView:nextImageView];
    [self.animation playAnimated:YES];
}

#pragma mark Miscellaneous

// Return an index in [0; upperBound[ different from forbiddenIndex (this correctly works when forbiddenIndex
// is set to kSlideshowNoIndex, in which case no valid index is excluded)
- (NSUInteger)randomIndexWithUpperBound:(NSUInteger)upperBound forbiddenIndex:(NSInteger)forbiddenIndex
{
    NSInteger randomIndex;
    do {
        randomIndex = arc4random() % upperBound;
    } while (randomIndex == forbiddenIndex);
    return randomIndex;
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationStepFinished:(HLSAnimationStep *)animationStep animated:(BOOL)animated
{
    if ([animationStep.tag isEqualToString:@"singleImage"]) {
        UIImageView *currentImageView = [self.imageViews objectAtIndex:m_currentImageViewIndex];
        if ([self.delegate respondsToSelector:@selector(slideshow:willHideImageWithNameOrPath:)]) {
            [self.delegate slideshow:self willHideImageWithNameOrPath:[self imageNameOrPathForImageView:currentImageView]];
        }
        
        UIImageView *nextImageView = [self.imageViews objectAtIndex:(m_currentImageViewIndex + 1) % 2];
        if ([self.delegate respondsToSelector:@selector(slideshow:willShowImageWithNameOrPath:)]) {
            [self.delegate slideshow:self willShowImageWithNameOrPath:[self imageNameOrPathForImageView:nextImageView]];
        }
    }
}

- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(slideshow:didShowImageWithNameOrPath:)]) {
        UIImageView *currentImageView = [self.imageViews objectAtIndex:m_currentImageViewIndex];
        [self.delegate slideshow:self didShowImageWithNameOrPath:[self imageNameOrPathForImageView:currentImageView]];
    }
}

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    UIImageView *currentImageView = [self.imageViews objectAtIndex:m_currentImageViewIndex];
    if ([self.delegate respondsToSelector:@selector(slideshow:didHideImageWithNameOrPath:)]) {
        [self.delegate slideshow:self didHideImageWithNameOrPath:[self imageNameOrPathForImageView:currentImageView]];
    }
    
    [self releaseImageView:currentImageView];
    
    if (! animation.terminating) {
        [self playNextAnimation];
    }
}

@end
