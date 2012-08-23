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
@property (nonatomic, retain) HLSAnimation *reverseAnimation;

@end

@implementation MultipleViewsAnimationDemoViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.rectangleView1 = nil;
    self.rectangleView2 = nil;
    self.rectangleView3 = nil;
    self.rectangleView4 = nil;
    self.playForwardButton = nil;
    self.playBackwardButton = nil;
    self.cancelButton = nil;
    self.terminateButton = nil;
    self.animatedSwitch = nil;
    self.blockingSwitch = nil;
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
}

#pragma mark Accessors and mutators

@synthesize rectangleView1 = m_rectangleView1;

@synthesize rectangleView2 = m_rectangleView2;

@synthesize rectangleView3 = m_rectangleView3;

@synthesize rectangleView4 = m_rectangleView4;

@synthesize playForwardButton = m_playForwardButton;

@synthesize playBackwardButton = m_playBackwardButton;

@synthesize cancelButton = m_cancelButton;

@synthesize terminateButton = m_terminateButton;

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
    self.terminateButton.hidden = NO;
    
    HLSViewAnimationStep *animationStep1 = [HLSViewAnimationStep animationStep];
    animationStep1.tag = @"step1";
    animationStep1.duration = 2.;
    HLSViewAnimation *viewAnimation11 = [HLSViewAnimation animation];
    [viewAnimation11 translateByVectorWithX:50.f y:60.f];
    [animationStep1 addViewAnimation:viewAnimation11 forView:self.rectangleView1];
    HLSViewAnimation *viewAnimation12 = [HLSViewAnimation animation];
    [viewAnimation12 translateByVectorWithX:40.f y:-10.f];
    viewAnimation12.alphaVariation = -0.4f;
    [animationStep1 addViewAnimation:viewAnimation12 forView:self.rectangleView2];
    HLSViewAnimation *viewAnimation13 = [HLSViewAnimation animation];
    [viewAnimation13 translateByVectorWithX:0.f y:100.f];
    [animationStep1 addViewAnimation:viewAnimation13 forView:self.rectangleView3];
    HLSViewAnimation *viewAnimation14 = [HLSViewAnimation animation];
    viewAnimation14.alphaVariation = -0.8f;
    [animationStep1 addViewAnimation:viewAnimation14 forView:self.rectangleView4];
    
    // Can also apply the same view animation step to all views
    HLSViewAnimationStep *animationStep2 = [HLSViewAnimationStep animationStep];
    animationStep2.tag = @"step2";
    animationStep2.duration = 1.;
    HLSViewAnimation *viewAnimation21 = [HLSViewAnimation animation];
    [viewAnimation21 translateByVectorWithX:80.f y:0.f];
    [animationStep2 addViewAnimation:viewAnimation21 forView:self.rectangleView1];
    [animationStep2 addViewAnimation:viewAnimation21 forView:self.rectangleView2];
    [animationStep2 addViewAnimation:viewAnimation21 forView:self.rectangleView3];
    [animationStep2 addViewAnimation:viewAnimation21 forView:self.rectangleView4];
    
    HLSViewAnimationStep *animationStep3 = [HLSViewAnimationStep animationStep];
    animationStep3.tag = @"step3";
    animationStep3.duration = 0.5;
    HLSViewAnimation *viewAnimation31 = [HLSViewAnimation animation];
    [viewAnimation31 scaleWithXFactor:1.5f yFactor:2.f];
    [animationStep3 addViewAnimation:viewAnimation31 forView:self.rectangleView1];
    HLSViewAnimation *viewAnimation32 = [HLSViewAnimation animation];
    [viewAnimation32 scaleWithXFactor:2.f yFactor:1.5f];
    viewAnimation32.alphaVariation = -0.3f;
    [animationStep3 addViewAnimation:viewAnimation32 forView:self.rectangleView2];
    HLSViewAnimation *viewAnimation33 = [HLSViewAnimation animation];
    [viewAnimation33 scaleWithXFactor:0.5f yFactor:0.5f];
    [animationStep3 addViewAnimation:viewAnimation33 forView:self.rectangleView3];
    
    // Create the animation and play it
    self.animation = [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithObjects:animationStep1,
                                                                animationStep2,
                                                                animationStep3,
                                                                nil]];
    self.animation.tag = @"multipleViewsAnimation";
    self.animation.lockingUI = self.blockingSwitch.on;
    self.animation.delegate = self;
    [self.animation playAnimated:self.animatedSwitch.on];
}

- (IBAction)playBackward:(id)sender
{
    self.playBackwardButton.hidden = YES;
    self.cancelButton.hidden = NO;
    self.terminateButton.hidden = NO;
    
    // Create the reverse animation
    self.reverseAnimation = [self.animation reverseAnimation];
    self.reverseAnimation.lockingUI = self.blockingSwitch.on;
    [self.reverseAnimation playAnimated:self.animatedSwitch.on];
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
    if ([animation.tag isEqualToString:@"multipleViewsAnimation"]) {
        self.playBackwardButton.hidden = NO;
    }
    else if ([animation.tag isEqualToString:@"reverse_multipleViewsAnimation"]) {
        self.playForwardButton.hidden = NO;
    }
    
    self.cancelButton.hidden = YES;
    self.terminateButton.hidden = YES;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Multiple view animation", @"Multiple view animation");
}

@end
