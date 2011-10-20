//
//  HLSKenBurnsSlideshow.m
//  CoconutKit
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSKenBurnsSlideshow.h"

#import "HLSAnimation.h"
#import "HLSLogger.h"

static const NSTimeInterval kKenBurnsZoomDefaultDuration = 4.;
static const NSTimeInterval kKenBurnsFadeDefaultDuration = 3.;

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
    self.clipsToBounds = YES;
    
    self.backgroundColor = [UIColor blackColor];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.imageViews = [NSArray array];
    self.animations = [NSMutableArray array];
    for (NSUInteger i = 0; i < 2; ++i) {
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        imageView.hidden = YES;
        [self addSubview:imageView];
        
        self.imageViews = [self.imageViews arrayByAddingObject:imageView];
        
        HLSAnimation *animation = [HLSAnimation animationWithAnimationStep:nil];
        [self.animations addObject:animation];
    }
    
    self.images = [NSArray array];
}

- (void)dealloc
{
    [self stop];
    
    self.imageViews = nil;
    self.animations = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize imageViews = m_imageViews;

@synthesize images = m_images;

@synthesize animations = m_animations;

#pragma mark Loading images

- (void)addImage:(UIImage *)image
{
    if (m_animating) {
        HLSLoggerWarn(@"Cannot add an image while the animation is running");
        return;
    }
    
    self.images = [self.images arrayByAddingObject:image];
}

#pragma mark Playing the slideshow

- (void)play
{
    if ([self.images count] == 0) {
        HLSLoggerInfo(@"No images loaded. Nothing to animate");
        return;
    }
    
    for (UIImageView *imageView in self.imageViews) {
        imageView.hidden = NO;
    }
    
    m_currentImageIndex = -1;
    
    [self playNextImageAnimation];
}

- (void)playNextImageAnimation
{
    // Find the involved image and image view and 
    m_currentImageIndex = (m_currentImageIndex + 1) % [self.images count];
    NSUInteger currentImageViewIndex = m_currentImageIndex % 2;
    
    UIImageView *imageView = [self.imageViews objectAtIndex:currentImageViewIndex];
    UIImage *image = [self.images objectAtIndex:m_currentImageIndex];
    imageView.image = image;
    imageView.clipsToBounds = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFill;       // The calculation below targets this special case
    imageView.alpha = 0.f;
    
    // TODO: This code is quite common (most notably in PDF generator code). Factor it somewhere where it can easily
    //       be reused
    // Aspect ratios of frame and image
    CGFloat imageViewRatio = CGRectGetWidth(imageView.frame) / CGRectGetHeight(imageView.frame);
    CGFloat imageRatio = image.size.width / image.size.height;
    
    // Calculate the scale which needs to be applied when the image is added to the image view with aspect fill content mode
    CGFloat zoomScale;
    // The image is more portrait-shaped than the image view
    if (floatlt(imageRatio, imageViewRatio)) {
        zoomScale = CGRectGetWidth(imageView.frame) / image.size.width;
    }
    // The image is more landscape-shaped than the image view
    else {
        zoomScale = CGRectGetHeight(imageView.frame) / image.size.height;
    }
    
    // Calculate the image size
    CGFloat resizedImageWidth = image.size.width * zoomScale;
    CGFloat resizedImageHeight = image.size.height * zoomScale;
    
    // Pick up a random initial scale factor. Must be >= 1, and not too large (1.4 should be sufficient)
    CGFloat scaleFactor = 1.f + 0.4f * (arc4random() % 1000) / 1000.f;
    
    // The image is centered in the image view. Calculate the maximum translation offsets we can apply for the selected
    // scale factor so that the image still covers the whole view
    CGFloat maxXOffset = (scaleFactor * resizedImageWidth - CGRectGetWidth(imageView.frame)) / 4.f;     // should be / 2.f theoretically, but was not perfect
    CGFloat maxYOffset = (scaleFactor * resizedImageHeight - CGRectGetHeight(imageView.frame)) / 4.f;   // should be / 2.f theoretically, but was not perfect
    
    // Pick up some random offsets
    CGFloat xOffset = (arc4random() % 1000) / 1000.f * maxXOffset;
    CGFloat yOffset = (arc4random() % 1000) / 1000.f * maxYOffset;
    
    // Apply initial transform
    imageView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(scaleFactor, scaleFactor),
                                                  CGAffineTransformMakeTranslation(xOffset, yOffset));
    
    // Pick up random scale factor to reach during the animation
    CGFloat finalScaleFactor = 1.f + 0.4f * (arc4random() % 1000) / 1000.f;
    CGFloat maxFinalXOffset = (finalScaleFactor * resizedImageWidth - CGRectGetWidth(imageView.frame)) / 4.f;     // should be / 2.f theoretically, but was not perfect
    CGFloat maxFinalYOffset = (finalScaleFactor * resizedImageHeight - CGRectGetHeight(imageView.frame)) / 4.f;   // should be / 2.f theoretically, but was not perfect
    CGFloat finalXOffset = (arc4random() % 1000) / 1000.f * maxFinalXOffset;
    CGFloat finalYOffset = (arc4random() % 1000) / 1000.f * maxFinalYOffset;
    
    // Create the corresponding animation
    HLSAnimation *animation = [self animationForImageView:imageView 
                                          WithScaleFactor:finalScaleFactor / scaleFactor
                                                  xOffset:finalXOffset - xOffset 
                                                  yOffset:finalYOffset - yOffset];
    [animation playAnimated:YES];
    
    [self.animations replaceObjectAtIndex:currentImageViewIndex withObject:animation];
}

- (void)stop
{
    for (HLSAnimation *animation in self.animations) {
        [animation cancel];
    }
}

#pragma mark Creating the animation

- (HLSAnimation *)animationForImageView:(UIImageView *)imageView
                        WithScaleFactor:(CGFloat)scaleFactor
                                xOffset:(CGFloat)xOffset
                                yOffset:(CGFloat)yOffset
{
    NSTimeInterval totalDuration = 2 * kKenBurnsFadeDefaultDuration + kKenBurnsZoomDefaultDuration;
    
    // To understand how to calculate the scale factor for each step, divide the total time interval in N equal intervals.
    // To get a smooth scale animation with total factor scaleFactor, each interval must be assigned a factor (scaleFactor)^(1/N),
    // so that the total scaleFactor is obtained by multiplying all of them. When grouping m such intervals, the corresponding
    // scale factor is therefore (scaleFactor)^(m/N), thus the formula for the scale factor of each step.
    
    // Fade in step: Scale + fade in
    HLSAnimationStep *fadeInAnimationStep = [HLSAnimationStep animationStep];
    fadeInAnimationStep.curve = UIViewAnimationCurveLinear;         // Linear for smooth transition between steps
    fadeInAnimationStep.duration = kKenBurnsFadeDefaultDuration;
    HLSViewAnimationStep *fadeInViewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
    CGFloat fadeInFactor = powf(scaleFactor, kKenBurnsFadeDefaultDuration / totalDuration);
    CGFloat fadeInXOffset = xOffset * kKenBurnsFadeDefaultDuration / totalDuration;
    CGFloat fadeInYOffset = yOffset * kKenBurnsFadeDefaultDuration / totalDuration;
    fadeInViewAnimationStep.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(fadeInFactor, fadeInFactor),
                                                                CGAffineTransformMakeTranslation(fadeInXOffset, fadeInYOffset));
    fadeInViewAnimationStep.alphaVariation = 1.f;
    [fadeInAnimationStep addViewAnimationStep:fadeInViewAnimationStep forView:imageView];
    
    // Main step: Only scale
    HLSAnimationStep *mainAnimationStep = [HLSAnimationStep animationStep];
    mainAnimationStep.curve = UIViewAnimationCurveLinear;         // Linear for smooth transition between steps
    mainAnimationStep.duration = kKenBurnsZoomDefaultDuration;
    mainAnimationStep.tag = @"zoom";
    HLSViewAnimationStep *mainViewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
    CGFloat mainFactor = powf(scaleFactor, kKenBurnsZoomDefaultDuration / totalDuration);
    CGFloat mainXOffset = xOffset * kKenBurnsZoomDefaultDuration / totalDuration;
    CGFloat mainYOffset = yOffset * kKenBurnsZoomDefaultDuration / totalDuration;
    mainViewAnimationStep.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(mainFactor, mainFactor),
                                                              CGAffineTransformMakeTranslation(mainXOffset, mainYOffset));
    [mainAnimationStep addViewAnimationStep:mainViewAnimationStep forView:imageView];
    
    // Fade out: Scale + fade out
    HLSAnimationStep *fadeOutAnimationStep = [HLSAnimationStep animationStep];
    fadeOutAnimationStep.curve = UIViewAnimationCurveLinear;         // Linear for smooth transition between steps
    fadeOutAnimationStep.duration = kKenBurnsFadeDefaultDuration;
    HLSViewAnimationStep *fadeOutViewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
    float fadeOutFactor = pow(scaleFactor, kKenBurnsFadeDefaultDuration / totalDuration);
    CGFloat fadeOutXOffset = xOffset * kKenBurnsFadeDefaultDuration / totalDuration;
    CGFloat fadeOutYOffset = yOffset * kKenBurnsFadeDefaultDuration / totalDuration;
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
