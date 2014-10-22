//
//  HLSSlideshow.m
//  CoconutKit
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Samuel Défago. All rights reserved.
//

#import "HLSSlideshow.h"

#import "HLSAssert.h"
#import "HLSLayerAnimationStep.h"
#import "HLSLogger.h"
#import "UIImage+HLSExtensions.h"
#import "UIView+HLSExtensions.h"

static const NSTimeInterval kSlideshowDefaultImageDuration = 4.;
static const NSTimeInterval kSlideshowDefaultTransitionDuration = 3.;
static const CGFloat kKenBurnsSlideshowMaxScaleFactorDelta = 0.4f;

static const NSInteger kSlideshowNoIndex = -1;

@interface HLSSlideshow () <HLSAnimationDelegate>

@property (nonatomic, strong) NSArray *imageViews;
@property (nonatomic, strong) HLSAnimation *animation;

@end

@implementation HLSSlideshow {
@private
    NSInteger _currentImageIndex;
    NSInteger _nextImageIndex;
    NSInteger _currentImageViewIndex;
}

#pragma mark Object creation and destruction

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self hlsSlideshowInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self hlsSlideshowInit];
    }
    return self;
}

- (void)hlsSlideshowInit
{
    self.clipsToBounds = YES;           // Uncomment this line to better see what is happening when debugging
    
    _currentImageIndex = kSlideshowNoIndex;
    
    self.imageViews = @[];
    for (NSUInteger i = 0; i < 2; ++i) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.autoresizingMask = HLSViewAutoresizingAll;
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
}

#pragma mark Accessors and mutators

- (void)setEffect:(HLSSlideshowEffect)effect
{
    if (self.running) {
        HLSLoggerWarn(@"The effect cannot be changed while the slideshow is running");
        return;
    }
    
    _effect = effect;
}

- (void)setImageNamesOrPaths:(NSArray *)imageNamesOrPaths
{   
    HLSAssertObjectsInEnumerationAreKindOfClass(imageNamesOrPaths, NSString);
    
    if (_imageNamesOrPaths == imageNamesOrPaths) {
        return;
    }
    
    if ([imageNamesOrPaths count] != 0) {
        if (_currentImageIndex != kSlideshowNoIndex) {
            // Try to find whether the current image is also in the new array. If the answer is
            // yes, start at the corresponding location to guarantee we won't see the same image
            // soon afterwards (if images are not displayed randomly, of course)
            NSString *currentImageNameOrPath = [_imageNamesOrPaths objectAtIndex:_currentImageIndex];
            NSUInteger currentImageIndexInNewArray = [imageNamesOrPaths indexOfObject:currentImageNameOrPath];
            if (currentImageIndexInNewArray != NSNotFound) {
                _currentImageIndex = currentImageIndexInNewArray;
            }
            // Otherwise start at the beginning
            else {
                _currentImageIndex = kSlideshowNoIndex;
            }
        }        
    }
    else {
        [self stop];
    }
    
    _imageNamesOrPaths = imageNamesOrPaths;
}

- (void)setImageDuration:(NSTimeInterval)imageDuration
{
    if (islessequal(imageDuration, 0.)) {
        HLSLoggerWarn(@"Image duration must be > 0; fixed to default value");
        imageDuration = kSlideshowDefaultImageDuration;
    }
    
    _imageDuration = imageDuration;
}

- (void)setTransitionDuration:(NSTimeInterval)transitionDuration
{
    if (isless(transitionDuration, 0.)) {
        HLSLoggerWarn(@"Transition duration must be >= 0; fixed to 0");
        transitionDuration = 0.;
    }
    
    _transitionDuration = transitionDuration;
}

- (BOOL)isRunning
{
    return self.animation.running;
}

- (BOOL)isPaused
{
    return self.animation.paused;
}

#pragma mark Playing the slideshow

- (void)play
{
    if (self.running) {
        HLSLoggerWarn(@"The slideshow is already running");
        return;
    }
    
    if ([self.imageNamesOrPaths count] == 0) {
        HLSLoggerInfo(@"No images to display. Nothing to animate");
        return;
    }
    
    _currentImageIndex = kSlideshowNoIndex;
    _nextImageIndex = kSlideshowNoIndex;
    _currentImageViewIndex = kSlideshowNoIndex;
    
    [self playAnimationForNextImage];
}

- (void)pause
{
    if (! self.running) {
        HLSLoggerDebug(@"The slideshow is not running");
        return;
    }
    
    if (self.paused) {
        HLSLoggerDebug(@"The slideshow is already paused");
        return;
    }
    
    [self.animation pause];
}

- (void)resume
{
    if (! self.paused) {
        HLSLoggerDebug(@"The slideshow has not been paused");
        return;
    }
    
    [self.animation resume];
}

- (void)stop
{
    if (! self.running) {
        HLSLoggerDebug(@"The slideshow is not running");
        return;
    }    
    
    [self.animation cancel];
    self.animation = nil;
    
    _currentImageIndex = kSlideshowNoIndex;
    _nextImageIndex = kSlideshowNoIndex;
    _currentImageViewIndex = kSlideshowNoIndex;
    
    for (UIImageView *imageView in self.imageViews) {
        imageView.image = nil;
    }
}

- (void)skipToNextImage
{
    if (! self.running) {
        return;
    }
    
    [self.animation terminate];
    self.animation = nil;
    
    for (UIImageView *imageView in self.imageViews) {
        [self releaseImageView:imageView];
    }
    [self playAnimationForNextImage];
}

- (void)skipToPreviousImage
{
    if (! self.running) {
        return;
    }
    
    [self.animation terminate];
    self.animation = nil;
    
    for (UIImageView *imageView in self.imageViews) {
        [self releaseImageView:imageView];
    }
    [self playAnimationForPreviousImage];
}

- (void)skipToImageWithNameOrPath:(NSString *)imageNameOrPath
{
    if (! self.running) {
        return;
    }
    
    NSUInteger imageIndex = [self.imageNamesOrPaths indexOfObject:imageNameOrPath];
    if (imageIndex == NSNotFound) {
        HLSLoggerWarn(@"The image %@ does not appear in the slideshow image list", imageNameOrPath);
        return;
    }
    
    [self.animation terminate];
    self.animation = nil;
    
    for (UIImageView *imageView in self.imageViews) {
        [self releaseImageView:imageView];
    }
    [self playAnimationForImageWithNameOrPath:imageNameOrPath];
}

- (NSString *)currentImageNameOrPath
{
    if (_currentImageViewIndex == kSlideshowNoIndex) {
        return nil;
    }
    
    if (self.running) {
        UIImageView *currentImageView = [self.imageViews objectAtIndex:_currentImageViewIndex];
        return [self imageNameOrPathForImageView:currentImageView];        
    }
    else {
        UIImageView *nextImageView = [self.imageViews objectAtIndex:(_currentImageViewIndex + 1) % 2];
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
        if (isless(imageRatio, frameRatio)) {
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
        if (isless(imageRatio, frameRatio)) {
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
    imageView.userInfo_hls = @{ @"imageNameOrPath" : imageNameOrPath };
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
    CGFloat scaleFactor = 1.f + kKenBurnsSlideshowMaxScaleFactorDelta * arc4random_uniform(1001) / 1000.f;
    
    // The image is centered in the image view. Calculate the maximum translation offsets we can apply for the selected
    // scale factor so that the image view still covers self
    CGFloat maxXOffset = (scaleFactor * CGRectGetWidth(imageView.frame) - CGRectGetWidth(self.frame)) / 2.f;
    CGFloat maxYOffset = (scaleFactor * CGRectGetHeight(imageView.frame) - CGRectGetHeight(self.frame)) / 2.f;
    
    // Pick up some random offsets. Use random factor in [-1;1]
    CGFloat xOffset = 2 * (arc4random_uniform(1001) / 1000.f - 0.5f) * maxXOffset;
    CGFloat yOffset = 2 * (arc4random_uniform(1001) / 1000.f - 0.5f) * maxYOffset;
    
    // Pick up random scale factor to reach at the end of the animation. Same constraints as above
    CGFloat finalScaleFactor = 1.f + kKenBurnsSlideshowMaxScaleFactorDelta * arc4random_uniform(1001) / 1000.f;
    CGFloat maxFinalXOffset = (finalScaleFactor * CGRectGetWidth(imageView.frame) - CGRectGetWidth(self.frame)) / 2.f;
    CGFloat maxFinalYOffset = (finalScaleFactor * CGRectGetHeight(imageView.frame) - CGRectGetHeight(self.frame)) / 2.f;
    CGFloat finalXOffset = 2 * (arc4random_uniform(1001) / 1000.f - 0.5f) * maxFinalXOffset;
    CGFloat finalYOffset = 2 * (arc4random_uniform(1001) / 1000.f - 0.5f) * maxFinalYOffset;
    
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
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    animationStep1.duration = 0.;
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 addToOpacity:-1.f];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:nextImageView];
    
    // Display the current image for the duration which has been set
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    animationStep2.tag = @"singleImage";
    animationStep2.duration = self.imageDuration;
    
    // Transition to the next image
    HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
    animationStep3.duration = transitionDuration;
    HLSLayerAnimation *layerAnimation31 = [HLSLayerAnimation animation];
    [layerAnimation31 addToOpacity:-1.f];
    [animationStep3 addLayerAnimation:layerAnimation31 forView:currentImageView];
    HLSLayerAnimation *layerAnimation32 = [HLSLayerAnimation animation];
    [layerAnimation32 addToOpacity:1.f];
    [animationStep3 addLayerAnimation:layerAnimation32 forView:nextImageView];
    
    return [HLSAnimation animationWithAnimationSteps:@[animationStep1, animationStep2, animationStep3]];
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
    
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    animationStep1.duration = 0.;
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 addToOpacity:-1.f];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:nextImageView];
    
    // User information attached: Not the first animation loop (and not reset after skipping
    // to the next or previous image)
    if ([userInfo objectForKey:@"scaleFactor"]) {
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
        
        HLSLayerAnimation *layerAnimation12 = [HLSLayerAnimation animation];
        CGFloat scaleFactor12 = powf(currentImageScaleFactor, self.transitionDuration / totalDuration);
        CGFloat xOffset12 = currentImageXOffset * self.transitionDuration / totalDuration;
        CGFloat yOffset12 = currentImageYOffset * self.transitionDuration / totalDuration;
        [layerAnimation12 scaleWithXFactor:scaleFactor12 yFactor:scaleFactor12];
        [layerAnimation12 translateByVectorWithX:xOffset12 y:yOffset12];
        [animationStep1 addLayerAnimation:layerAnimation12 forView:currentImageView];
    }
    
    CGFloat nextImageScaleFactor = 0.f;
    CGFloat nextImageXOffset = 0.f;
    CGFloat nextImageYOffset = 0.f;
    [self randomlyMoveAndScaleImageView:nextImageView 
                            scaleFactor:&nextImageScaleFactor 
                                xOffset:&nextImageXOffset 
                                yOffset:&nextImageYOffset];
    
    // Displaying the current image
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    animationStep2.tag = @"singleImage";
    animationStep2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];         // Linear for smooth transition between steps
    animationStep2.duration = self.imageDuration;
    
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    CGFloat scaleFactor21 = powf(currentImageScaleFactor, self.imageDuration / totalDuration);
    CGFloat xOffset21 = currentImageXOffset * self.imageDuration / totalDuration;
    CGFloat yOffset21 = currentImageYOffset * self.imageDuration / totalDuration;
    [layerAnimation21 scaleWithXFactor:scaleFactor21 yFactor:scaleFactor21];
    [layerAnimation21 translateByVectorWithX:xOffset21 y:yOffset21];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:currentImageView];
    
    // Transition
    HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
    animationStep3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];         // Linear for smooth transition between steps
    animationStep3.duration = self.transitionDuration;
    
    HLSLayerAnimation *layerAnimation31 = [HLSLayerAnimation animation];
    CGFloat scaleFactor31 = powf(currentImageScaleFactor, self.transitionDuration / totalDuration);
    CGFloat xOffset31 = currentImageXOffset * self.transitionDuration / totalDuration;
    CGFloat yOffset31 = currentImageYOffset * self.transitionDuration / totalDuration;
    [layerAnimation31 scaleWithXFactor:scaleFactor31 yFactor:scaleFactor31];
    [layerAnimation31 translateByVectorWithX:xOffset31 y:yOffset31];
    [layerAnimation31 addToOpacity:-1.f];
    [animationStep3 addLayerAnimation:layerAnimation31 forView:currentImageView];
    
    HLSLayerAnimation *layerAnimation32 = [HLSLayerAnimation animation];
    CGFloat scaleFactor32 = powf(nextImageScaleFactor, self.transitionDuration / totalDuration);
    CGFloat xOffset32 = nextImageXOffset * self.transitionDuration / totalDuration;
    CGFloat yOffset32 = nextImageYOffset * self.transitionDuration / totalDuration;
    [layerAnimation32 scaleWithXFactor:scaleFactor32 yFactor:scaleFactor32];
    [layerAnimation32 translateByVectorWithX:xOffset32 y:yOffset32];
    [layerAnimation32 addToOpacity:1.f];
    [animationStep3 addLayerAnimation:layerAnimation32 forView:nextImageView];
    
    HLSAnimation *animation = [HLSAnimation animationWithAnimationSteps:@[animationStep1,
                                                                         animationStep2,
                                                                         animationStep3]];
    animation.userInfo = @{ @"scaleFactor" : @(nextImageScaleFactor),
                            @"xOffset" : @(nextImageXOffset),
                            @"yOffset" : @(nextImageYOffset) };
    return animation;
}

- (HLSAnimation *)translationAnimationWithCurrentImageView:(UIImageView *)currentImageView
                                             nextImageView:(UIImageView *)nextImageView
                                                   xOffset:(CGFloat)xOffset
                                                   yOffset:(CGFloat)yOffset
{
    // Move the next image to its initial position
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    animationStep1.duration = 0.;
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 translateByVectorWithX:xOffset y:yOffset];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:nextImageView];
    
    // Display the current image for the duration which has been set (identity view animation step)
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    animationStep2.tag = @"singleImage";
    animationStep2.duration = self.imageDuration;
    
    // Transition to the next image
    HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
    animationStep3.duration = self.transitionDuration;
    HLSLayerAnimation *layerAnimation31 = [HLSLayerAnimation animation];
    [layerAnimation31 translateByVectorWithX:-xOffset y:-yOffset];
    [animationStep3 addLayerAnimation:layerAnimation31 forView:currentImageView];
    HLSLayerAnimation *layerAnimation32 = [HLSLayerAnimation animation];
    [layerAnimation32 translateByVectorWithX:-xOffset y:-yOffset];
    [animationStep3 addLayerAnimation:layerAnimation32 forView:nextImageView];
    
    return [HLSAnimation animationWithAnimationSteps:@[animationStep1, animationStep2, animationStep3]];
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
            _currentImageIndex = _nextImageIndex;
            _nextImageIndex = [self randomIndexWithUpperBound:numberOfImages forbiddenIndex:_currentImageIndex];
        }
        else {
            _currentImageIndex = 0;
            _nextImageIndex = 0;
        }
    }
    else {
        _currentImageIndex = (_currentImageIndex + 1) % numberOfImages;
        _nextImageIndex = (_currentImageIndex + 1) % numberOfImages;
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
    
    _currentImageIndex = imageIndex;
    
    if (self.random) {
        if (numberOfImages > 1) {
            // Avoid displaying the same image twice in a row
            _nextImageIndex = [self randomIndexWithUpperBound:numberOfImages forbiddenIndex:_currentImageIndex];
        }
        else {
            NSAssert(imageIndex == 0, @"Only one image, must have index 0");
            _nextImageIndex = 0;
        }
    }
    else {
        _nextImageIndex = (_currentImageIndex + 1) % numberOfImages;
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
            _currentImageIndex = [self randomIndexWithUpperBound:numberOfImages forbiddenIndex:_currentImageIndex];
            _nextImageIndex = [self randomIndexWithUpperBound:numberOfImages forbiddenIndex:_currentImageIndex];
        }
        else {
            _currentImageIndex = 0;
            _nextImageIndex = 0;
        }
    }
    else {
        _currentImageIndex = (_currentImageIndex + 1) % numberOfImages;
        _nextImageIndex = (_currentImageIndex + 1) % numberOfImages;
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
            _currentImageIndex = [self randomIndexWithUpperBound:numberOfImages forbiddenIndex:_currentImageIndex];
            _nextImageIndex = [self randomIndexWithUpperBound:numberOfImages forbiddenIndex:_currentImageIndex];
        }
        else {
            _currentImageIndex = 0;
            _nextImageIndex = 0;
        }
    }
    else {
        // Add numberOfImages to avoid issues when crossing 0
        _currentImageIndex = (_currentImageIndex - 1 + numberOfImages) % numberOfImages;
        _nextImageIndex = (_currentImageIndex - 1 + numberOfImages) % numberOfImages;
    }
    
    [self animateImages];
}

- (void)animateImages
{    
    // Find the image views to use for the current / next images. Only unused image views (i.e. with image == nil)
    // have to be filled at each step.
    _currentImageViewIndex = (_currentImageViewIndex + 1) % 2;
    UIImageView *currentImageView = [self.imageViews objectAtIndex:_currentImageViewIndex];
    if (! currentImageView.image) {
        NSString *currentImagePath = [self.imageNamesOrPaths objectAtIndex:_currentImageIndex];
        [self prepareImageView:currentImageView withImageNameOrPath:currentImagePath];
    }
    
    UIImageView *nextImageView = [self.imageViews objectAtIndex:(_currentImageViewIndex + 1) % 2];
    if (! nextImageView.image) {
        NSString *nextImagePath = [self.imageNamesOrPaths objectAtIndex:_nextImageIndex];
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
        randomIndex = arc4random_uniform((u_int32_t)upperBound);
    } while (randomIndex == forbiddenIndex);
    return randomIndex;
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animation:(HLSAnimation *)animation didFinishStep:(HLSAnimationStep *)animationStep animated:(BOOL)animated
{
    if ([animationStep.tag isEqualToString:@"singleImage"]) {
        UIImageView *currentImageView = [self.imageViews objectAtIndex:_currentImageViewIndex];
        if ([self.delegate respondsToSelector:@selector(slideshow:willHideImageWithNameOrPath:)]) {
            [self.delegate slideshow:self willHideImageWithNameOrPath:[self imageNameOrPathForImageView:currentImageView]];
        }
        
        UIImageView *nextImageView = [self.imageViews objectAtIndex:(_currentImageViewIndex + 1) % 2];
        if ([self.delegate respondsToSelector:@selector(slideshow:willShowImageWithNameOrPath:)]) {
            [self.delegate slideshow:self willShowImageWithNameOrPath:[self imageNameOrPathForImageView:nextImageView]];
        }
    }
}

- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(slideshow:didShowImageWithNameOrPath:)]) {
        UIImageView *currentImageView = [self.imageViews objectAtIndex:_currentImageViewIndex];
        [self.delegate slideshow:self didShowImageWithNameOrPath:[self imageNameOrPathForImageView:currentImageView]];
    }
}

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    UIImageView *currentImageView = [self.imageViews objectAtIndex:_currentImageViewIndex];
    if ([self.delegate respondsToSelector:@selector(slideshow:didHideImageWithNameOrPath:)]) {
        [self.delegate slideshow:self didHideImageWithNameOrPath:[self imageNameOrPathForImageView:currentImageView]];
    }
    
    [self releaseImageView:currentImageView];
    
    if (! animation.terminating) {
        [self playNextAnimation];
    }
}

@end
