//
//  MultipleViewsAnimationDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/13/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "MultipleViewsAnimationDemoViewController.h"

@interface MultipleViewsAnimationDemoViewController ()

@property (nonatomic, retain) HLSAnimation *animation;

- (void)playForwardButtonClicked:(id)sender;
- (void)playBackwardButtonClicked:(id)sender;

@end

@implementation MultipleViewsAnimationDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.title = NSLocalizedString(@"Multiple view animation", @"Multiple view animation");
    }
    return self;
}

- (void)dealloc
{    
    self.animation = nil;
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.rectangleView1 = nil;
    self.rectangleView2 = nil;
    self.rectangleView3 = nil;
    self.rectangleView4 = nil;
    self.playForwardButton = nil;
    self.playBackwardButton = nil;
    self.animatedLabel = nil;
    self.animatedSwitch = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.playForwardButton setTitle:NSLocalizedString(@"Play forward", @"Play forward") 
                            forState:UIControlStateNormal];
    [self.playForwardButton addTarget:self 
                               action:@selector(playForwardButtonClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.playBackwardButton setTitle:NSLocalizedString(@"Play backward", @"Play backward") 
                             forState:UIControlStateNormal];
    [self.playBackwardButton addTarget:self 
                                action:@selector(playBackwardButtonClicked:)
                      forControlEvents:UIControlEventTouchUpInside];
    self.playBackwardButton.hidden = YES;
    
    self.animatedLabel.text = NSLocalizedString(@"Animated", @"Animated");
    self.animatedSwitch.on = YES;
}

#pragma mark Accessors and mutators

@synthesize rectangleView1 = m_rectangleView1;

@synthesize rectangleView2 = m_rectangleView2;

@synthesize rectangleView3 = m_rectangleView3;

@synthesize rectangleView4 = m_rectangleView4;

@synthesize playForwardButton = m_playForwardButton;

@synthesize playBackwardButton = m_playBackwardButton;

@synthesize animatedLabel = m_animatedLabel;

@synthesize animatedSwitch = m_animatedSwitch;

@synthesize animation = m_animation;

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark Event callbacks

- (void)playForwardButtonClicked:(id)sender
{
    self.playForwardButton.hidden = YES;
    
    // Several views animated; build the animation step from a set of view animation steps
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    animationStep1.duration = 2.f;
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:50.f 
                                                                                                          deltaY:60.f];
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:self.rectangleView1];
    HLSViewAnimationStep *viewAnimationStep12 = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithTransform:CGAffineTransformMakeRotation(-M_PI)
                                                                                                  alphaVariation:-0.4f];
    [animationStep1 addViewAnimationStep:viewAnimationStep12 forView:self.rectangleView2];
    HLSViewAnimationStep *viewAnimationStep13 = [HLSViewAnimationStep viewAnimationStepAnimatingViewFromFrame:self.rectangleView3.frame
                                                                                                      toFrame:self.rectangleView4.frame];
    [animationStep1 addViewAnimationStep:viewAnimationStep13 forView:self.rectangleView3];
    HLSViewAnimationStep *viewAnimationStep14 = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithAlphaVariation:-0.8f];
    [animationStep1 addViewAnimationStep:viewAnimationStep14 forView:self.rectangleView4];
    
    // Can also apply the same view animation step to all views
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    animationStep2.duration = 1.f;
    HLSViewAnimationStep *viewAnimationStep2 = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithTransform:CGAffineTransformMakeScale(1.5f, 1.5f)
                                                                                                 alphaVariation:0.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep2 forView:self.rectangleView1];
    [animationStep2 addViewAnimationStep:viewAnimationStep2 forView:self.rectangleView2];
    [animationStep2 addViewAnimationStep:viewAnimationStep2 forView:self.rectangleView3];
    [animationStep2 addViewAnimationStep:viewAnimationStep2 forView:self.rectangleView4];
    
    // In fact, there is an even easier way to achieve this
    HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStepTranslatingViews:[NSArray arrayWithObjects:self.rectangleView1,
                                                                                        self.rectangleView2,
                                                                                        self.rectangleView3,
                                                                                        self.rectangleView4,
                                                                                        nil]
                                                                            withDeltaX:0.f
                                                                                deltaY:50.f
                                                                        alphaVariation:0.f];
    animationStep3.duration = 0.8f;
    
    // Create the animation and play it
    self.animation = [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithObjects:animationStep1,
                                                                animationStep2,
                                                                animationStep3,
                                                                nil]];
    self.animation.tag = @"multipleViewsAnimation";
    self.animation.lockingUI = YES;
    self.animation.delegate = self;
    [self.animation playAnimated:self.animatedSwitch.on];
}

- (void)playBackwardButtonClicked:(id)sender
{
    self.playBackwardButton.hidden = YES;
    
    // Create the reverse animation
    HLSAnimation *reverseAnimation = [self.animation reverseAnimation];
    [reverseAnimation playAnimated:self.animatedSwitch.on];
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated
{
    HLSLoggerInfo(@"Animation %@, animated = %@", animation.tag, HLSStringFromBool(animated));
}

- (void)animationStepFinished:(HLSAnimationStep *)animationStep animated:(BOOL)animated
{
    HLSLoggerInfo(@"Animated = %@", HLSStringFromBool(animated));
}

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    HLSLoggerInfo(@"Animation %@, animated = %@", animation.tag, HLSStringFromBool(animated));
    
    // Can find which animation ended using its tag
    if ([animation.tag isEqual:@"multipleViewsAnimation"]) {
        self.playBackwardButton.hidden = NO;
    }
    else if ([animation.tag isEqual:@"reverse_multipleViewsAnimation"]) {
        self.playForwardButton.hidden = NO;
    }
}

@end
