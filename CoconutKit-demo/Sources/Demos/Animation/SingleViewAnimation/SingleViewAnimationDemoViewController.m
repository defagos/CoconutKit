//
//  SingleViewAnimationDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/13/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "SingleViewAnimationDemoViewController.h"

@interface SingleViewAnimationDemoViewController ()

@property (nonatomic, retain) HLSAnimation *animation;
@property (nonatomic, retain) HLSAnimation *reverseAnimation;

@end

@implementation SingleViewAnimationDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super initWithNibName:[self className] bundle:nil])) {
        
    }
    return self;
}

- (void)releaseViews
{
    [super releaseViews];
    
    [self.animation cancel];
    self.animation = nil;
    
    [self.reverseAnimation cancel];
    self.reverseAnimation = nil;
    
    self.rectangleView = nil;
    self.playForwardButton = nil;
    self.playBackwardButton = nil;
    self.cancelButton = nil;
    self.animatedSwitch = nil;
    self.blockingSwitch = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playBackwardButton.hidden = YES;
    self.cancelButton.hidden = YES;
    
    self.animatedSwitch.on = YES;
    self.blockingSwitch.on = NO;
}

#pragma mark Accessors and mutators

@synthesize rectangleView = m_rectangleView;

@synthesize playForwardButton = m_playForwardButton;

@synthesize playBackwardButton = m_playBackwardButton;

@synthesize cancelButton = m_cancelButton;

@synthesize animatedSwitch = m_animatedSwitch;

@synthesize blockingSwitch = m_blockingSwitch;

@synthesize animation = m_animation;

@synthesize reverseAnimation = m_reverseAnimation;

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark Event callbacks

- (IBAction)playForward:(id)sender
{
    self.playForwardButton.hidden = YES;
    self.cancelButton.hidden = NO;
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    animationStep1.duration = 2.;
    animationStep1.curve = UIViewAnimationCurveEaseIn;
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.transform = CGAffineTransformMakeTranslation(100.f, 100.f);
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:self.rectangleView];
        
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    animationStep2.duration = 1.;
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep21.alphaVariation = -0.3f;
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:self.rectangleView];
    
    HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep31 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep31.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    [animationStep3 addViewAnimationStep:viewAnimationStep31 forView:self.rectangleView];
    
    HLSAnimationStep *animationStep4 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep41 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep41.transform = CGAffineTransformMakeRotation(M_PI_4);
    [animationStep4 addViewAnimationStep:viewAnimationStep41 forView:self.rectangleView];
    
    HLSAnimationStep *animationStep5 = [HLSAnimationStep animationStep];
    animationStep5.duration = 1.;
    animationStep5.curve = UIViewAnimationCurveLinear;
    HLSViewAnimationStep *viewAnimationStep51 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep51.transform = CGAffineTransformMakeTranslation(0.f, 200.f);
    [animationStep5 addViewAnimationStep:viewAnimationStep51 forView:self.rectangleView];
    
    HLSAnimationStep *animationStep6 = [HLSAnimationStep animationStep];
    animationStep6.curve = UIViewAnimationCurveLinear;
    HLSViewAnimationStep *viewAnimationStep61 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep61.transform = CGAffineTransformMakeRotation(M_PI_4);
    viewAnimationStep61.alphaVariation = 0.3f;
    [animationStep6 addViewAnimationStep:viewAnimationStep61 forView:self.rectangleView];
    
    // Create the animation and play it
    self.animation = [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithObjects:animationStep1,
                                                                animationStep2,
                                                                animationStep3,
                                                                animationStep4,
                                                                animationStep5,
                                                                animationStep6,
                                                                nil]];
    self.animation.tag = @"singleViewAnimation";
    self.animation.lockingUI = self.blockingSwitch.on;
    self.animation.delegate = self;
    [self.animation playAnimated:self.animatedSwitch.on];
}

- (IBAction)playBackward:(id)sender
{
    self.playBackwardButton.hidden = YES;
    self.cancelButton.hidden = NO;
    
    // Create the reverse animation
    self.reverseAnimation = [self.animation reverseAnimation];
    self.reverseAnimation.lockingUI = self.blockingSwitch.on;
    [self.reverseAnimation playAnimated:self.animatedSwitch.on];
}

- (IBAction)cancelButton:(id)sender
{
    if (self.animation.running) {
        self.playBackwardButton.hidden = NO;
        [self.animation cancel];
    }
    if (self.reverseAnimation.running) {
        self.playForwardButton.hidden = NO;
        [self.reverseAnimation cancel];
    }

    self.cancelButton.hidden = YES;
}

#pragma mark HLSAnimationDelegate protocol implementation

- (IBAction)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated
{
    HLSLoggerInfo(@"Animation %@, animated = %@", animation.tag, HLSStringFromBool(animated));
}

- (IBAction)animationStepFinished:(HLSAnimationStep *)animationStep animated:(BOOL)animated
{
    HLSLoggerInfo(@"Animated = %@", HLSStringFromBool(animated));
}

- (IBAction)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    HLSLoggerInfo(@"Animation %@, animated = %@", animation.tag, HLSStringFromBool(animated));
    
    // Can find which animation ended using its tag
    if ([animation.tag isEqualToString:@"singleViewAnimation"]) {
        self.playBackwardButton.hidden = NO;
    }
    else if ([animation.tag isEqualToString:@"reverse_singleViewAnimation"]) {
        self.playForwardButton.hidden = NO;
    }
    
    self.cancelButton.hidden = YES;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Single view animation", @"Single view animation");
}

@end
