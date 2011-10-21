//
//  HLSKenBurnsSlideshow.m
//  CoconutKit
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSKenBurnsSlideshow.h"

#import "HLSAnimation.h"
#import "HLSFloat.h"
#import "HLSLogger.h"

static const NSTimeInterval kKenBurnsDefaultImageDuration = 10.;
static const NSTimeInterval kKenBurnsDefaultTransitionDuration = 3.;
static const CGFloat kKenBurnsMaxScaleFactorDelta = 0.4f;

@interface HLSKenBurnsSlideshow () <HLSAnimationDelegate>

- (void)hlsKenBurnsSlideshowInit;

@property (nonatomic, retain) NSArray *imageViews;
@property (nonatomic, retain) NSMutableArray *animations;

- (void)playNextImageAnimation;

- (HLSAnimation *)animationForImageView:(UIImageView *)imageView
                        WithScaleFactor:(CGFloat)scaleFactor
                                xOffset:(CGFloat)xOffset
                                yOffset:(CGFloat)yOffset;

@end

@implementation HLSKenBurnsSlideshow

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self hlsKenBurnsSlideshowInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self hlsKenBurnsSlideshowInit];
    }
    return self;
}

- (void)hlsKenBurnsSlideshowInit
{
    self.clipsToBounds = YES;           // Uncomment this line to better see what is happening when debugging
    
    self.imageViews = [NSArray array];
    self.animations = [NSMutableArray array];
    for (NSUInteger i = 0; i < 2; ++i) {
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.hidden = YES;
        [self addSubview:imageView];
        
        self.imageViews = [self.imageViews arrayByAddingObject:imageView];
        
        HLSAnimation *animation = [HLSAnimation animationWithAnimationStep:nil];
        [self.animations addObject:animation];
    }
    
    self.images = [NSArray array];
    
    self.imageDuration = kKenBurnsDefaultImageDuration;
    self.transitionDuration = kKenBurnsDefaultTransitionDuration;
    self.random = NO;
}

- (void)dealloc
{
    [self stop];
    
    self.imageViews = nil;
    self.images = nil;
    self.animations = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize imageViews = m_imageViews;

@synthesize images = m_images;

- (void)setImages:(NSArray *)images
{    
    if (m_running) {
        HLSLoggerWarn(@"Cannot add an image while the animation is running");
        return;
    }
    
    if (m_images == images) {
        return;
    }
    
    [m_images release];
    m_images = [images retain];
}

@synthesize animations = m_animations;

@synthesize imageDuration = m_imageDuration;

- (void)setImageDuration:(NSTimeInterval)imageDuration
{
    if (doublelt(imageDuration, 0.)) {
        HLSLoggerWarn(@"Image duration must be > 0; fixed to default value");
        imageDuration = kKenBurnsDefaultImageDuration;
    }
    
    m_imageDuration = imageDuration;
}

@synthesize transitionDuration = m_transitionDuration;

- (void)setTransitionDuration:(NSTimeInterval)transitionDuration
{
    if (doublelt(transitionDuration, 0.)) {
        HLSLoggerWarn(@"Transition duration must be > 0; fixed to 2/5 of total duration");
        transitionDuration = 2. * self.imageDuration / 5.;
    }
    
    if (doublelt(self.imageDuration - 2 * transitionDuration, 0.)) {
        HLSLoggerWarn(@"Transition duration must not exceed half the total duration");
        transitionDuration = self.imageDuration / 2.;
    }
    
    m_transitionDuration = transitionDuration;
}

@synthesize random = m_random;

#pragma mark Playing the slideshow

- (void)play
{
    if ([self.images count] == 0) {
        HLSLoggerInfo(@"No images loaded. Nothing to animate");
        return;
    }
    
    m_running = YES;
    
    for (UIImageView *imageView in self.imageViews) {
        imageView.hidden = NO;
    }
    
    m_currentImageIndex = -1;
    m_currentImageViewIndex = -1;
    
    [self playNextImageAnimation];
}

- (void)playNextImageAnimation
{
    // Find the involved image
    if (self.random) {
        m_currentImageIndex = arc4random() % [self.images count];
    }
    else {
        m_currentImageIndex = (m_currentImageIndex + 1) % [self.images count];
    }
    
    // Find the involved image view
    m_currentImageViewIndex = (m_currentImageViewIndex + 1) % 2;
    UIImageView *imageView = [self.imageViews objectAtIndex:m_currentImageViewIndex];
    UIImage *image = [self.images objectAtIndex:m_currentImageIndex];
    
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
    imageView.center = CGPointMake(roundf(CGRectGetWidth(self.frame) / 2.f), roundf(CGRectGetHeight(self.frame) / 2.f));
    imageView.image = image;
    imageView.alpha = 0.f;
    
    // Pick up a random initial scale factor. Must be >= 1, and not too large. Use random factor in [0;1]
    CGFloat scaleFactor = 1.f + kKenBurnsMaxScaleFactorDelta * (arc4random() % 1001) / 1000.f;
    
    // The image is centered in the image view. Calculate the maximum translation offsets we can apply for the selected
    // scale factor so that the image view still covers self
    CGFloat maxXOffset = (scaleFactor * scaledImageWidth - CGRectGetWidth(self.frame)) / 2.f;
    CGFloat maxYOffset = (scaleFactor * scaledImageHeight - CGRectGetHeight(self.frame)) / 2.f;
    
    // Pick up some random offsets. Use random factor in [-1;1]
    CGFloat xOffset = 2 * ((arc4random() % 1001) / 1000.f - 0.5f) * maxXOffset;
    CGFloat yOffset = 2 * ((arc4random() % 1001) / 1000.f - 0.5f) * maxYOffset;
    
    // Apply initial transform to get initial image view position
    imageView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(scaleFactor, scaleFactor),
                                                  CGAffineTransformMakeTranslation(xOffset, yOffset));
    
    // Pick up random scale factor to reach at the end of the animation. Same constraints as above
    CGFloat finalScaleFactor = 1.f + kKenBurnsMaxScaleFactorDelta * (arc4random() % 1001) / 1000.f;
    CGFloat maxFinalXOffset = (finalScaleFactor * scaledImageWidth - CGRectGetWidth(self.frame)) / 2.f;
    CGFloat maxFinalYOffset = (finalScaleFactor * scaledImageHeight - CGRectGetHeight(self.frame)) / 2.f;
    CGFloat finalXOffset = 2 * ((arc4random() % 1001) / 1000.f - 0.5f) * maxFinalXOffset;
    CGFloat finalYOffset = 2 * ((arc4random() % 1001) / 1000.f - 0.5f) * maxFinalYOffset;
    
    // Create the corresponding animation and plays it
    HLSAnimation *animation = [self animationForImageView:imageView 
                                          WithScaleFactor:finalScaleFactor / scaleFactor
                                                  xOffset:finalXOffset - xOffset 
                                                  yOffset:finalYOffset - yOffset];
    [animation playAnimated:YES];
    
    [self.animations replaceObjectAtIndex:m_currentImageViewIndex withObject:animation];
}

- (void)stop
{
    for (HLSAnimation *animation in self.animations) {
        [animation cancel];
    }
    
    m_running = NO;
}

#pragma mark Creating the animation

- (HLSAnimation *)animationForImageView:(UIImageView *)imageView
                        WithScaleFactor:(CGFloat)scaleFactor
                                xOffset:(CGFloat)xOffset
                                yOffset:(CGFloat)yOffset
{
    // To understand how to calculate the scale factor for each step, divide the total time interval in N equal intervals.
    // To get a smooth scale animation with total factor scaleFactor, each interval must be assigned a factor (scaleFactor)^(1/N),
    // so that the total scaleFactor is obtained by multiplying all of them. When grouping m such intervals, the scale factor
    // for the m intervals is therefore (scaleFactor)^(m/N), thus the formula for the scale factor of each step.
    
    // Fade in step: Scale + fade in
    HLSAnimationStep *fadeInAnimationStep = [HLSAnimationStep animationStep];
    fadeInAnimationStep.curve = UIViewAnimationCurveLinear;         // Linear for smooth transition between steps
    fadeInAnimationStep.duration = self.transitionDuration;
    HLSViewAnimationStep *fadeInViewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
    CGFloat fadeInFactor = powf(scaleFactor, self.transitionDuration / self.imageDuration);
    CGFloat fadeInXOffset = xOffset * self.transitionDuration / self.imageDuration;
    CGFloat fadeInYOffset = yOffset * self.transitionDuration / self.imageDuration;
    fadeInViewAnimationStep.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(fadeInFactor, fadeInFactor),
                                                                CGAffineTransformMakeTranslation(fadeInXOffset, fadeInYOffset));
    fadeInViewAnimationStep.alphaVariation = 1.f;
    [fadeInAnimationStep addViewAnimationStep:fadeInViewAnimationStep forView:imageView];
    
    // Main step: Only scale
    HLSAnimationStep *mainAnimationStep = [HLSAnimationStep animationStep];
    mainAnimationStep.curve = UIViewAnimationCurveLinear;         // Linear for smooth transition between steps
    NSTimeInterval mainDuration = self.imageDuration - 2 * self.transitionDuration; 
    mainAnimationStep.duration = mainDuration;
    mainAnimationStep.tag = @"zoom";
    HLSViewAnimationStep *mainViewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
    CGFloat mainFactor = powf(scaleFactor, mainDuration / self.imageDuration);
    CGFloat mainXOffset = xOffset * mainDuration / self.imageDuration;
    CGFloat mainYOffset = yOffset * mainDuration / self.imageDuration;
    mainViewAnimationStep.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(mainFactor, mainFactor),
                                                              CGAffineTransformMakeTranslation(mainXOffset, mainYOffset));
    [mainAnimationStep addViewAnimationStep:mainViewAnimationStep forView:imageView];
    
    // Fade out: Scale + fade out
    HLSAnimationStep *fadeOutAnimationStep = [HLSAnimationStep animationStep];
    fadeOutAnimationStep.curve = UIViewAnimationCurveLinear;         // Linear for smooth transition between steps
    fadeOutAnimationStep.duration = self.transitionDuration;
    HLSViewAnimationStep *fadeOutViewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
    float fadeOutFactor = pow(scaleFactor, self.transitionDuration / self.imageDuration);
    CGFloat fadeOutXOffset = xOffset * self.transitionDuration / self.imageDuration;
    CGFloat fadeOutYOffset = yOffset * self.transitionDuration / self.imageDuration;
    fadeOutViewAnimationStep.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(fadeOutFactor, fadeOutFactor),
                                                                 CGAffineTransformMakeTranslation(fadeOutXOffset, fadeOutYOffset));
    fadeOutViewAnimationStep.alphaVariation = -1.f;
    [fadeOutAnimationStep addViewAnimationStep:fadeOutViewAnimationStep forView:imageView];
    
    HLSAnimation *animation = [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithObjects:fadeInAnimationStep, 
                                                                         mainAnimationStep, 
                                                                         fadeOutAnimationStep, 
                                                                         nil]];
    animation.delegate = self;
    animation.bringToFront = YES;
    
    return animation;
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationStepFinished:(HLSAnimationStep *)animationStep animated:(BOOL)animated
{
    if ([animationStep.tag isEqual:@"zoom"]) {
        [self playNextImageAnimation];
    }
}

@end
