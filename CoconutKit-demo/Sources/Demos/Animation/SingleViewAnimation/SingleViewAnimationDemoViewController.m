//
//  SingleViewAnimationDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/13/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "SingleViewAnimationDemoViewController.h"

#import <objc/runtime.h>

@interface SingleViewAnimationDemoViewController ()

@property (nonatomic, retain) HLSAnimation *animation;
@property (nonatomic, retain) HLSAnimation *reverseAnimation;

- (void)updateUserInterface;

@end

@implementation SingleViewAnimationDemoViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
        
    self.rectangleView = nil;
    self.playForwardButton = nil;
    self.playBackwardButton = nil;
    self.cancelButton = nil;
    self.terminateButton = nil;
    self.animatedSwitch = nil;
    self.blockingSwitch = nil;
    self.delayedSwitch = nil;
    self.fasterSwitch = nil;
    self.animation = nil;
    self.reverseAnimation = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playBackwardButton.hidden = YES;
    self.cancelButton.hidden = YES;
    self.terminateButton.hidden = YES;
    
    self.animatedSwitch.on = YES;
    self.blockingSwitch.on = NO;
    self.delayedSwitch.on = NO;
    self.fasterSwitch.on = NO;
    
    [self updateUserInterface];
}

#pragma mark Accessors and mutators

@synthesize rectangleView = m_rectangleView;

@synthesize playForwardButton = m_playForwardButton;

@synthesize playBackwardButton = m_playBackwardButton;

@synthesize cancelButton = m_cancelButton;

@synthesize terminateButton = m_terminateButton;

@synthesize animatedSwitch = m_animatedSwitch;

@synthesize blockingSwitch = m_blockingSwitch;

@synthesize delayedLabel = m_delayedLabel;

@synthesize delayedSwitch = m_delayedSwitch;

@synthesize fasterSwitch = m_fasterSwitch;

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
    self.terminateButton.hidden = NO;
    
    HLSViewAnimationStep *animationStep1 = [HLSViewAnimationStep animationStep];
    animationStep1.tag = @"step1";
    animationStep1.duration = 2.;
    animationStep1.curve = UIViewAnimationCurveEaseIn;
    HLSViewAnimation *viewAnimation11 = [HLSViewAnimation viewAnimation];
    [viewAnimation11 translateByVectorWithX:100.f y:100.f];
    [animationStep1 addViewAnimation:viewAnimation11 forView:self.rectangleView];
    
    HLSViewAnimationStep *animationStep2 = [HLSViewAnimationStep animationStep];
    animationStep2.tag = @"step2";
    animationStep2.duration = 1.;
    HLSViewAnimation *viewAnimation21 = [HLSViewAnimation viewAnimation];
    viewAnimation21.alphaVariation = -0.3f;
    [animationStep2 addViewAnimation:viewAnimation21 forView:self.rectangleView];
    
    HLSViewAnimationStep *animationStep3 = [HLSViewAnimationStep animationStep];
    animationStep3.tag = @"step3";
    HLSViewAnimation *viewAnimation31 = [HLSViewAnimation viewAnimation];
    [viewAnimation31 scaleWithXFactor:1.5f yFactor:1.5f];
    [animationStep3 addViewAnimation:viewAnimation31 forView:self.rectangleView];
    
    HLSViewAnimationStep *animationStep4 = [HLSViewAnimationStep animationStep];
    animationStep4.tag = @"step4";
    HLSViewAnimation *viewAnimation41 = [HLSViewAnimation viewAnimation];
    [viewAnimation41 rotateByAngle:M_PI_4];
    [animationStep4 addViewAnimation:viewAnimation41 forView:self.rectangleView];
    
    HLSViewAnimationStep *animationStep5 = [HLSViewAnimationStep animationStep];
    animationStep5.tag = @"step5";
    animationStep5.duration = 1.;
    animationStep5.curve = UIViewAnimationCurveLinear;
    HLSViewAnimation *viewAnimation51 = [HLSViewAnimation viewAnimation];
    [viewAnimation51 translateByVectorWithX:0.f y:200.f];
    [animationStep5 addViewAnimation:viewAnimation51 forView:self.rectangleView];
    
    HLSViewAnimationStep *animationStep6 = [HLSViewAnimationStep animationStep];
    animationStep6.tag = @"step6";
    animationStep6.curve = UIViewAnimationCurveLinear;
    HLSViewAnimation *viewAnimation61 = [HLSViewAnimation viewAnimation];
    [viewAnimation61 rotateByAngle:M_PI_4];
    viewAnimation61.alphaVariation = 0.3f;
    [animationStep6 addViewAnimation:viewAnimation61 forView:self.rectangleView];
    
    // Create the animation and play it
    self.animation = [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithObjects:animationStep1,
                                                                animationStep2,
                                                                animationStep3,
                                                                animationStep4,
                                                                animationStep5,
                                                                animationStep6,
                                                                nil]];
    if (self.fasterSwitch.on) {
        self.animation = [self.animation animationWithDuration:2.];
    }
    self.animation.tag = @"singleViewAnimation";
    self.animation.lockingUI = self.blockingSwitch.on;
    self.animation.delegate = self;
    
    if (! self.delayedSwitch.on) {
        [self.animation playAnimated:self.animatedSwitch.on];
    }
    else {
        [self.animation playAfterDelay:2.];
    }
}

- (IBAction)playBackward:(id)sender
{
    self.playBackwardButton.hidden = YES;
    self.cancelButton.hidden = NO;
    self.terminateButton.hidden = NO;
    
    // Create the reverse animation
    self.reverseAnimation = [self.animation reverseAnimation];
    self.reverseAnimation.lockingUI = self.blockingSwitch.on;
    
    if (! self.delayedSwitch.on) {
        [self.reverseAnimation playAnimated:self.animatedSwitch.on];    
    }
    else {
        [self.reverseAnimation playAfterDelay:1.];
    }
}

- (IBAction)cancel:(id)sender
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
    self.terminateButton.hidden = YES;
}

- (IBAction)terminate:(id)sender
{
    if (self.animation.running) {
        self.playBackwardButton.hidden = NO;
        [self.animation terminate];
    }
    if (self.reverseAnimation.running) {
        self.playForwardButton.hidden = NO;
        [self.reverseAnimation terminate];
    }
    
    self.cancelButton.hidden = YES;
    self.terminateButton.hidden = YES;
}

- (IBAction)toggleAnimated:(id)sender
{
    [self updateUserInterface];
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated
{
    HLSLoggerInfo(@"Animation %@ will start, animated = %@", animation.tag, HLSStringFromBool(animated));
}

- (void)animationStepFinished:(HLSViewAnimationStep *)animationStep animated:(BOOL)animated
{
    HLSLoggerInfo(@"Step %@ finished, animated = %@", animationStep.tag, HLSStringFromBool(animated));
}

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    HLSLoggerInfo(@"Animation %@ did stop, animated = %@", animation.tag, HLSStringFromBool(animated));
    
    // Can find which animation ended using its tag
    if ([animation.tag isEqualToString:@"singleViewAnimation"]) {
        self.playBackwardButton.hidden = NO;
    }
    else if ([animation.tag isEqualToString:@"reverse_singleViewAnimation"]) {
        self.playForwardButton.hidden = NO;
    }
    
    self.cancelButton.hidden = YES;
    self.terminateButton.hidden = YES;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Single view animation", @"Single view animation");
}

#pragma mark Miscellaneous

- (void)updateUserInterface
{
    if (self.animatedSwitch.on) {
        self.delayedLabel.hidden = NO;
        self.delayedSwitch.hidden = NO;
    }
    else {
        self.delayedLabel.hidden = YES;
        self.delayedSwitch.hidden = YES;
    }
}

@end
