//
//  SingleViewAnimationDemoViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 2/13/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "SingleViewAnimationDemoViewController.h"

@interface SingleViewAnimationDemoViewController ()

@property (nonatomic, retain) HLSAnimation *animation;

- (void)playForwardButtonClicked:(id)sender;
- (void)playBackwardButtonClicked:(id)sender;

@end

@implementation SingleViewAnimationDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.title = NSLocalizedString(@"Single view animation", @"Single view animation");
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
    
    self.rectangleView = nil;
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

@synthesize rectangleView = m_rectangleView;

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
    
    // Only a single view to animate; can use the convenience constructor of HLSAnimation step for animation
    // creation using less code
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStepTranslatingView:self.rectangleView
                                                                           withDeltaX:100.f
                                                                               deltaY:100.f];
    animationStep1.duration = 2.f;
    animationStep1.curve = UIViewAnimationCurveEaseIn;
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStepUpdatingView:self.rectangleView
                                                                withAlphaVariation:-0.3f];
    animationStep1.duration = 1.f;
    
    // We can of course also create a view animation step and apply it to the view to animate
    HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep3 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep3.transform = CGAffineTransformMakeRotation(M_PI/4);
    [animationStep3 addViewAnimationStep:viewAnimationStep3 forView:self.rectangleView];
    
    HLSAnimationStep *animationStep4 = [HLSAnimationStep animationStepUpdatingView:self.rectangleView
                                                                     withTransform:CGAffineTransformMakeScale(2.f, 3.f) 
                                                                    alphaVariation:0.f];
    animationStep4.duration = 1.f;
    animationStep4.curve = UIViewAnimationCurveLinear;
    
    // Create the animation and play it
    self.animation = [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithObjects:animationStep1,
                                                                animationStep2,
                                                                animationStep3,
                                                                animationStep4,
                                                                nil]];
    self.animation.tag = @"singleViewAnimation";
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
    if ([animation.tag isEqual:@"singleViewAnimation"]) {
        self.playBackwardButton.hidden = NO;
    }
    else if ([animation.tag isEqual:@"reverse_singleViewAnimation"]) {
        self.playForwardButton.hidden = NO;
    }
}

@end
