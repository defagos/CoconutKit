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

static const NSTimeInterval kSlideshowDefaultImageDuration = 10.;
static const NSTimeInterval kSlideshowDefaultTransitionDuration = 3.;
static const CGFloat kKenBurnsSlideshowMaxScaleFactorDelta = 0.4f;

@interface HLSSlideshow () <HLSAnimationDelegate>

- (void)hlsSlideshowInit;

@property (nonatomic, retain) NSArray *imageViews;
@property (nonatomic, retain) HLSAnimation *animation;

- (UIImage *)imageForNameOrPath:(NSString *)imageNameOrPath;

- (HLSAnimation *)crossDissolveAnimationWithCurrentImageView:(UIImageView *)currentImageView
                                               nextImageView:(UIImageView *)nextImageView
                                          transitionDuration:(NSTimeInterval)transitionDuration;
- (HLSAnimation *)kenBurnsAnimationWithCurrentImageView:(UIImageView *)currentImageView
                                          nextImageView:(UIImageView *)nextImageView;
- (HLSAnimation *)animationForEffect:(HLSSlideShowEffect)effect
                    currentImageView:(UIImageView *)currentImageView
                       nextImageView:(UIImageView *)nextImageView;

- (void)playNextAnimation;

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
    
    self.imageViews = [NSArray array];
    for (NSUInteger i = 0; i < 2; ++i) {
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.hidden = YES;
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
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize effect = m_effect;

@synthesize imageViews = m_imageViews;

@synthesize imageNamesOrPaths = m_imageNamesOrPaths;

- (void)setImageNamesOrPaths:(NSArray *)imageNamesOrPaths
{   
    HLSAssertObjectsInEnumerationAreKindOfClass(imageNamesOrPaths, NSString);
    
    if (m_imageNamesOrPaths == imageNamesOrPaths) {
        return;
    }
    
    if (imageNamesOrPaths) {
        if (m_currentImageIndex != -1) {
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
                m_currentImageIndex = -1;
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

#if 0
- (void)setImageDuration:(NSTimeInterval)imageDuration
{
    if (doublele(imageDuration, 0.)) {
        HLSLoggerWarn(@"Image duration must be > 0; fixed to default value");
        imageDuration = kSlideshowDefaultImageDuration;
    }
    
    m_imageDuration = imageDuration;
}
#endif

@synthesize transitionDuration = m_transitionDuration;

#if 0
- (void)setTransitionDuration:(NSTimeInterval)transitionDuration
{
    if (doublelt(transitionDuration, 0.)) {
        HLSLoggerWarn(@"Transition duration must be >= 0; fixed to 0");
        transitionDuration = 0.;
    }
        
    m_transitionDuration = transitionDuration;
}
#endif

@synthesize random = m_random;

- (BOOL)isRunning
{
    return self.animation.running;
}

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
    
    for (UIImageView *imageView in self.imageViews) {
        imageView.hidden = NO;
    }
    
    m_currentImageIndex = -1;
    m_nextImageIndex = -1;
    m_currentImageViewIndex = -1;
    
    [self playNextAnimation];
}

- (void)stop
{
    if (! self.animation.running) {
        HLSLoggerInfo(@"The slideshow is not running");
        return;
    }
    
    [self.animation cancel];    
}

- (void)skipToNextImage
{
    // TODO: Cancel current animation, but still play the next one next
}

- (void)skipToPreviousImage
{
    // TODO: Cancel current animation, and play the previous one next
}

#pragma mark Creating the animation

- (UIImage *)imageForNameOrPath:(NSString *)imageNameOrPath
{
    UIImage *image = [UIImage imageNamed:imageNameOrPath];
    if (! image) {
        image = [UIImage imageWithContentsOfFile:imageNameOrPath];
    }
    if (! image) {
        HLSLoggerWarn(@"Missing image %@", imageNameOrPath);
        image = [UIImage imageWithColor:self.backgroundColor];
    }
    return image;
}

// TODO: Problem with animation steps during which nothing has to be animated: Their duration is 0. Fix in HLSAnimation.m
//       e.g. by adding a hidden dummy view to every animation step (of course, this dummy view must not be seen from
//       the outside)
- (HLSAnimation *)crossDissolveAnimationWithCurrentImageView:(UIImageView *)currentImageView
                                               nextImageView:(UIImageView *)nextImageView
                                          transitionDuration:(NSTimeInterval)transitionDuration
{
    // Display the current image for the duration which has been set (identity view animation step)
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    animationStep1.duration = self.imageDuration;
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = -0.01f;            // TODO: See above
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:currentImageView];
    
    // Transition to the next image
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    animationStep2.duration = transitionDuration;
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep21.alphaVariation = -0.99f;            // TODO: See above
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:currentImageView];
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep22.alphaVariation = 1.f;
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:nextImageView];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithObjects:animationStep1, animationStep2, nil]];
}

- (HLSAnimation *)kenBurnsAnimationWithCurrentImageView:(UIImageView *)currentImageView
                                          nextImageView:(UIImageView *)nextImageView
{
    return nil;
}

- (HLSAnimation *)animationForEffect:(HLSSlideShowEffect)effect
                    currentImageView:(UIImageView *)currentImageView
                       nextImageView:(UIImageView *)nextImageView
{
    HLSAnimation *animation = nil;
    switch (effect) {
        case HLSSlideShowEffectNone: {
            animation = [self crossDissolveAnimationWithCurrentImageView:currentImageView
                                                           nextImageView:nextImageView 
                                                      transitionDuration:0.];
            break;
        }
            
        case HLSSlideShowEffectCrossDissolve: {
            animation = [self crossDissolveAnimationWithCurrentImageView:currentImageView
                                                           nextImageView:nextImageView
                                                      transitionDuration:self.transitionDuration];
            break;
        }
            
        case HLSSlideShowEffectKenBurns: {
            animation = [self kenBurnsAnimationWithCurrentImageView:currentImageView
                                                      nextImageView:nextImageView];
            break;
        }
            
        case HLSSlideShowEffectHorizontalRibbon: {
            // TODO
            return nil;
            break;
        }
            
        case HLSSlideshowEffectInverseHorizontalRibbon: {
            // TODO
            return nil;
            break;
        }
            
        case HLSSlideshowEffectVerticalRibbon: {
            // TODO
            return nil;
            break;
        }
            
        case HLSSlideshowEffectInverseVerticalRibbon: {
            // TODO
            return nil;
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

- (void)displayImage:(UIImage *)image inImageView:(UIImageView *)imageView
{
    // TODO: This code is quite common (most notably in PDF generator code). Factor it somewhere where it can easily
    //       be reused
    // Aspect ratios of frame and image
    CGFloat frameRatio = CGRectGetWidth(self.frame) / CGRectGetHeight(self.frame);
    CGFloat imageRatio = image.size.width / image.size.height;
    
    // Calculate the scale which needs to be applied to get aspect fill behavior for the image view
    CGFloat zoomScale;
    // The image is more portrait-shaped than self
    if (floatlt(imageRatio, frameRatio)) {
        zoomScale = CGRectGetWidth(self.frame) / image.size.width;
    }
    // The image is more landscape-shaped than self
    else {
        zoomScale = CGRectGetHeight(self.frame) / image.size.height;
    }
    
    // Update the image view to match the image dimensions with an aspect fill behavior inside self
    CGFloat scaledImageWidth = image.size.width * zoomScale;
    CGFloat scaledImageHeight = image.size.height * zoomScale;
    imageView.bounds = CGRectMake(0.f, 0.f, scaledImageWidth, scaledImageHeight);
    imageView.center = CGPointMake(floorf(CGRectGetWidth(self.frame) / 2.f), floorf(CGRectGetHeight(self.frame) / 2.f));
    imageView.image = image;
}

- (void)playNextAnimation
{    
    // Find the current / next images
    if (self.random) {
        m_currentImageIndex = arc4random() % [self.imageNamesOrPaths count];
        m_nextImageIndex = arc4random() % [self.imageNamesOrPaths count];
    }
    else {
        m_currentImageIndex = (m_currentImageIndex + 1) % [self.imageNamesOrPaths count];
        m_nextImageIndex = (m_currentImageIndex + 1) % [self.imageNamesOrPaths count];
    }
    
    // Find the image views to use for the current / next images. Only unused image views (i.e. with image == nil)
    // have to be filled at each step
    m_currentImageViewIndex = (m_currentImageViewIndex + 1) % 2;
    UIImageView *currentImageView = [self.imageViews objectAtIndex:m_currentImageViewIndex];
    if (! currentImageView.image) {
        currentImageView.alpha = 1.f;
        NSString *currentImagePath = [self.imageNamesOrPaths objectAtIndex:m_currentImageIndex];
        UIImage *currentImage = [self imageForNameOrPath:currentImagePath];
        [self displayImage:currentImage inImageView:currentImageView];
    }
    
    UIImageView *nextImageView = [self.imageViews objectAtIndex:(m_currentImageViewIndex + 1) % 2];
    if (! nextImageView.image) {
        nextImageView.alpha = 0.f;
        NSString *nextImagePath = [self.imageNamesOrPaths objectAtIndex:m_nextImageIndex];
        UIImage *nextImage = [self imageForNameOrPath:nextImagePath];
        [self displayImage:nextImage inImageView:nextImageView];
    }
    
    // Create and play the animation
    HLSAnimation *animation = [self animationForEffect:self.effect
                                      currentImageView:currentImageView
                                         nextImageView:nextImageView];
    [animation playAnimated:YES];
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    // Done with the current image view. Mark it as unused so that we know it must be initialized again
    // when a new image is assigned to it
    UIImageView *currentImageView = [self.imageViews objectAtIndex:m_currentImageViewIndex];
    currentImageView.image = nil;
    
    [self playNextAnimation];
}

@end
