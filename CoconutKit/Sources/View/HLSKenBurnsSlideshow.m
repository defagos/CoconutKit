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
@property (nonatomic, retain) NSArray *images;
@property (nonatomic, retain) NSMutableArray *animations;

- (void)playNextImageAnimation;

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
        imageView.contentMode = UIViewContentModeScaleAspectFill;
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
    m_currentImageIndex = (m_currentImageIndex + 1) % [self.images count];
    NSUInteger currentImageViewIndex = m_currentImageIndex % 2;
    
    UIImageView *imageView = [self.imageViews objectAtIndex:currentImageViewIndex];
    imageView.image = [self.images objectAtIndex:m_currentImageIndex];
    imageView.transform = CGAffineTransformIdentity;
    imageView.alpha = 0.f;
    
    NSTimeInterval totalDuration = 2 * kKenBurnsFadeDefaultDuration + kKenBurnsZoomDefaultDuration;
    CGFloat factor = 1.3f;          // TODO: Should be custom
    CGFloat xOffset = 30.f;
    CGFloat yOffset = 30.f;
    
    HLSAnimationStep *fadeInAnimationStep = [HLSAnimationStep animationStep];
    fadeInAnimationStep.curve = UIViewAnimationCurveLinear;
    fadeInAnimationStep.duration = kKenBurnsFadeDefaultDuration;
    HLSViewAnimationStep *fadeInViewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
    CGFloat fadeInFactor = powf(factor, kKenBurnsFadeDefaultDuration / totalDuration);
    CGFloat fadeInXOffset = xOffset * kKenBurnsFadeDefaultDuration / totalDuration;
    CGFloat fadeInYOffset = yOffset * kKenBurnsFadeDefaultDuration / totalDuration;
    fadeInViewAnimationStep.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(fadeInFactor, fadeInFactor),
                                                                CGAffineTransformMakeTranslation(fadeInXOffset, fadeInYOffset));
    fadeInViewAnimationStep.alphaVariation = 1.f;
    [fadeInAnimationStep addViewAnimationStep:fadeInViewAnimationStep forView:imageView];
    
    HLSAnimationStep *mainAnimationStep = [HLSAnimationStep animationStep];
    mainAnimationStep.curve = UIViewAnimationCurveLinear;
    mainAnimationStep.duration = kKenBurnsZoomDefaultDuration;
    mainAnimationStep.tag = @"zoom";
    HLSViewAnimationStep *mainViewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
    CGFloat mainFactor = powf(factor, kKenBurnsZoomDefaultDuration / totalDuration);
    CGFloat mainXOffset = xOffset * kKenBurnsZoomDefaultDuration / totalDuration;
    CGFloat mainYOffset = yOffset * kKenBurnsZoomDefaultDuration / totalDuration;
    mainViewAnimationStep.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(mainFactor, mainFactor),
                                                              CGAffineTransformMakeTranslation(mainXOffset, mainYOffset));
    [mainAnimationStep addViewAnimationStep:mainViewAnimationStep forView:imageView];
    
    HLSAnimationStep *fadeOutAnimationStep = [HLSAnimationStep animationStep];
    fadeOutAnimationStep.curve = UIViewAnimationCurveLinear;
    fadeOutAnimationStep.duration = kKenBurnsFadeDefaultDuration;
    HLSViewAnimationStep *fadeOutViewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
    float fadeOutFactor = pow(factor, kKenBurnsFadeDefaultDuration / totalDuration);
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
    [animation playAnimated:YES];
    
    [self.animations replaceObjectAtIndex:currentImageViewIndex withObject:animation];
}

- (void)stop
{
    for (HLSAnimation *animation in self.animations) {
        [animation cancel];
    }
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationStepFinished:(HLSAnimationStep *)animationStep animated:(BOOL)animated
{
    if ([animationStep.tag isEqual:@"zoom"]) {
        [self playNextImageAnimation];
    }
}

@end
