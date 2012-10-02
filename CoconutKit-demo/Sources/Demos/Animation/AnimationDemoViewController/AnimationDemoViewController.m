//
//  AnimationDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/13/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "AnimationDemoViewController.h"

@interface AnimationDemoViewController ()

@property (nonatomic, retain) HLSAnimation *animation;

- (void)updateUserInterface;

- (SEL)selectorForAnimationWithIndex:(NSUInteger)index;
- (NSUInteger)repeatCount;
- (void)playAnimation:(HLSAnimation *)animation;

- (HLSAnimation *)animation;
- (HLSAnimation *)animation1;
- (HLSAnimation *)animation2;
- (HLSAnimation *)animation3;
- (HLSAnimation *)animation4;
- (HLSAnimation *)animation5;
- (HLSAnimation *)animation6;
- (HLSAnimation *)animation7;
- (HLSAnimation *)animation8;
- (HLSAnimation *)animation9;
- (HLSAnimation *)animation10;
- (HLSAnimation *)animation11;
- (HLSAnimation *)animation12;
- (HLSAnimation *)animation13;

@end

@implementation AnimationDemoViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.rectangleView1 = nil;
    self.rectangleView2 = nil;
    self.animationPickerView = nil;
    self.resetButton = nil;
    self.playForwardButton = nil;
    self.playBackwardButton = nil;
    self.pauseButton = nil;
    self.cancelButton = nil;
    self.terminateButton = nil;
    self.animatedSwitch = nil;
    self.lockingUISwitch = nil;
    self.delayedSwitch = nil;
    self.overrideDurationSwitch = nil;
    self.loopingSwitch = nil;
    self.repeatCountSlider = nil;
    self.repeatCountLabel = nil;
    self.animation = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.animationPickerView.dataSource = self;
    self.animationPickerView.delegate = self;
    
    self.resetButton.hidden = YES;
    self.pauseButton.hidden = YES;
    self.cancelButton.hidden = YES;
    self.terminateButton.hidden = YES;
    
    self.animatedSwitch.on = YES;
    self.lockingUISwitch.on = NO;
    self.delayedSwitch.on = NO;
    self.overrideDurationSwitch.on = NO;
    
    self.loopingSwitch.on = NO;
    
    // Apply a perspective to sublayers
    CATransform3D sublayerTransform = self.view.layer.sublayerTransform;
    sublayerTransform.m34 = -1.f / 1000.f;
    
    [self updateUserInterface];
}

#pragma mark Accessors and mutators

@synthesize rectangleView1 = m_rectangleView1;

@synthesize rectangleView2 = m_rectangleView2;

@synthesize animationPickerView = m_animationPickerView;

@synthesize resetButton = m_resetButton;

@synthesize playForwardButton = m_playForwardButton;

@synthesize playBackwardButton = m_playBackwardButton;

@synthesize pauseButton = m_pauseButton;

@synthesize cancelButton = m_cancelButton;

@synthesize terminateButton = m_terminateButton;

@synthesize animatedSwitch = m_animatedSwitch;

@synthesize lockingUISwitch = m_lockingUISwitch;

@synthesize delayedSwitch = m_delayedSwitch;

@synthesize overrideDurationSwitch = m_overrideDurationSwitch;

@synthesize loopingSwitch = m_loopingSwitch;

@synthesize repeatCountSlider = m_repeatCountSlider;

@synthesize repeatCountLabel = m_repeatCountLabel;

@synthesize animation = m_animation;

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Single view animation", @"Single view animation");
}

#pragma mark UI

- (void)updateUserInterface
{
    NSUInteger repeatCount = [self repeatCount];
    if (repeatCount == NSUIntegerMax) {
        self.repeatCountLabel.text = @"inf";
    }
    else {
        self.repeatCountLabel.text = [NSString stringWithFormat:@"%d", repeatCount];
    }
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated
{
    HLSLoggerInfo(@"Animation %@ will start, animated = %@, running = %@, cancelling = %@, terminating = %@", animation.tag,
                  HLSStringFromBool(animated), HLSStringFromBool(animation.running), HLSStringFromBool(animation.cancelling),
                  HLSStringFromBool(animation.terminating));
}

- (void)animation:(HLSAnimation *)animation didFinishStepWithTag:(NSString *)animationStepTag animated:(BOOL)animated
{
    HLSLoggerInfo(@"Step with tag %@ finished, animated = %@, running = %@, cancelling = %@, terminating = %@", animationStepTag,
                  HLSStringFromBool(animated), HLSStringFromBool(animation.running), HLSStringFromBool(animation.cancelling),
                  HLSStringFromBool(animation.terminating));
}

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    HLSLoggerInfo(@"Animation %@ did stop, animated = %@, running = %@, cancelling = %@, terminating = %@", animation.tag,
                  HLSStringFromBool(animated), HLSStringFromBool(animation.running), HLSStringFromBool(animation.cancelling),
                  HLSStringFromBool(animation.terminating));
}

#pragma mark UIPickerViewDataSource protocol implementation

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSUInteger animationMethodCount = 0;
    while ([self respondsToSelector:[self selectorForAnimationWithIndex:animationMethodCount + 1]]) {
        ++animationMethodCount;
    }
    
    return animationMethodCount;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%d", row + 1];
}

#pragma mark Event callbacks

- (IBAction)reset:(id)sender
{

}

- (IBAction)playForward:(id)sender
{
    [self playAnimation:[self animation]];
}

- (IBAction)playBackward:(id)sender
{
    [self playAnimation:[[self animation] reverseAnimation]];
}

- (IBAction)pause:(id)sender
{
    if (! self.animation.paused) {
        [self.animation pause];
    }
    else {
        [self.animation resume];
    }
}

- (IBAction)cancel:(id)sender
{
    [self.animation cancel];
}

- (IBAction)terminate:(id)sender
{
    [self.animation terminate];
}

- (IBAction)repeatCountChanged:(id)sender
{
    [self updateUserInterface];
}

#pragma mark Animations

- (SEL)selectorForAnimationWithIndex:(NSUInteger)index
{
    NSString *selectorName = [NSString stringWithFormat:@"animation%d", index];
    return NSSelectorFromString(selectorName);
}

- (NSUInteger)repeatCount
{
    if (floateq(self.repeatCountSlider.value, self.repeatCountSlider.maximumValue)) {
        return NSUIntegerMax;
    }
    else {
        return roundf(self.repeatCountSlider.value);
    }
}

- (void)playAnimation:(HLSAnimation *)animation
{
    NSUInteger repeatCount = [self repeatCount];
    if (self.overrideDurationSwitch.on) {
        animation = [animation animationWithDuration:5.];
    }
    if (self.delayedSwitch.on) {
        [animation playWithRepeatCount:repeatCount afterDelay:3.];
    }
    else {
        [animation playWithRepeatCount:repeatCount animated:self.animatedSwitch.on];
    }
}

- (HLSAnimation *)animation
{    
    SEL selector = [self selectorForAnimationWithIndex:[self.animationPickerView selectedRowInComponent:0] + 1];
    HLSAnimation *animation = [self performSelector:selector];
    if (self.loopingSwitch.on) {
        animation = [animation loopAnimation];
    }
    if (self.overrideDurationSwitch) {
        
    }
    animation.delegate = self;
    animation.lockingUI = self.lockingUISwitch.on;
    return animation;
}

- (HLSAnimation *)animation1
{
    // Layer translation, one view
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 translateByVectorWithX:100.f y:20.f];
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    animationStep1.tag = @"step1";
    [animationStep1 addLayerAnimation:layerAnimation11 forView:self.rectangleView1];
    return [HLSAnimation animationWithAnimationStep:animationStep1];;
}

- (HLSAnimation *)animation2
{
    // Layer rotation around the z axis, one view
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 rotateByAngle:M_PI_4];
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    animationStep1.tag = @"step1";
    [animationStep1 addLayerAnimation:layerAnimation11 forView:self.rectangleView1];
    return [HLSAnimation animationWithAnimationStep:animationStep1];;
}

- (HLSAnimation *)animation3
{
    // Layer rotation around the x axis, one view
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 rotateByAngle:M_PI_4 aboutVectorWithX:0.f y:1.f z:0.f];
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    animationStep1.tag = @"step1";
    [animationStep1 addLayerAnimation:layerAnimation11 forView:self.rectangleView1];
    return [HLSAnimation animationWithAnimationStep:animationStep1];;
}

- (HLSAnimation *)animation4
{
    // Layer scaling, one view
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 scaleWithXFactor:2.f yFactor:3.f];
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    animationStep1.tag = @"step1";
    [animationStep1 addLayerAnimation:layerAnimation11 forView:self.rectangleView1];
    return [HLSAnimation animationWithAnimationStep:animationStep1];;
}

- (HLSAnimation *)animation5
{
    // View translation, one view
    HLSViewAnimation *viewAnimation11 = [HLSViewAnimation animation];
    [viewAnimation11 translateByVectorWithX:100.f y:20.f];
    HLSViewAnimationStep *animationStep1 = [HLSViewAnimationStep animationStep];
    animationStep1.tag = @"step1";
    [animationStep1 addViewAnimation:viewAnimation11 forView:self.rectangleView1];
    return [HLSAnimation animationWithAnimationStep:animationStep1];;
}

- (HLSAnimation *)animation6
{
    // View scaling, one view
    HLSViewAnimation *viewAnimation11 = [HLSViewAnimation animation];
    [viewAnimation11 scaleWithXFactor:2.f yFactor:3.f];
    HLSViewAnimationStep *animationStep1 = [HLSViewAnimationStep animationStep];
    animationStep1.tag = @"step1";
    [animationStep1 addViewAnimation:viewAnimation11 forView:self.rectangleView1];
    return [HLSAnimation animationWithAnimationStep:animationStep1];;
}

- (HLSAnimation *)animation7
{
    // Layer opacity
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 addToOpacity:-0.5f];
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    animationStep1.tag = @"step1";
    [animationStep1 addLayerAnimation:layerAnimation11 forView:self.rectangleView1];
    return [HLSAnimation animationWithAnimationStep:animationStep1];
}

- (HLSAnimation *)animation8
{
    // View opacity
    HLSViewAnimation *viewAnimation11 = [HLSViewAnimation animation];
    [viewAnimation11 addToAlpha:-0.5f];
    HLSViewAnimationStep *animationStep1 = [HLSViewAnimationStep animationStep];
    animationStep1.tag = @"step1";
    [animationStep1 addViewAnimation:viewAnimation11 forView:self.rectangleView1];
    return [HLSAnimation animationWithAnimationStep:animationStep1];
}

- (HLSAnimation *)animation9
{
    // Empty animation. Also triggers willStart and didStop callbacks
    return [HLSAnimation animationWithAnimationStep:nil];
}

- (HLSAnimation *)animation10
{
    // Pulse animation (when repeated)
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 scaleWithXFactor:2.f yFactor:2.f];
    [layerAnimation11 addToOpacity:-1.f];
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    animationStep1.tag = @"step1";
    animationStep1.duration = 0.8;
    animationStep1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:self.rectangleView1];
        
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    animationStep2.tag = @"step2";
    animationStep2.duration = 0.5;
    
    HLSLayerAnimation *layerAnimation31 = [HLSLayerAnimation animation];
    [layerAnimation31 scaleWithXFactor:1.f / 2.f yFactor:1.f / 2.f];
    [layerAnimation31 addToOpacity:1.f];
    HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
    animationStep3.tag = @"step3";
    animationStep3.duration = 0.;
    [animationStep3 addLayerAnimation:layerAnimation31 forView:self.rectangleView1];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithObjects:animationStep1, animationStep2, animationStep3, nil]];
}

- (HLSAnimation *)animation11
{
    // Animate several views similarly at once, and with several transformations applied during each step
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 translateByVectorWithX:50.f y:50.f];
    [layerAnimation11 rotateByAngle:M_PI_4];
    [layerAnimation11 scaleWithXFactor:2.f yFactor:2.f];
    [layerAnimation11 addToOpacity:-0.5f];
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    animationStep1.tag = @"step1";
    animationStep1.duration = 0.6;
    [animationStep1 addLayerAnimation:layerAnimation11 forView:self.rectangleView1];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:self.rectangleView2];
    
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    [layerAnimation21 translateByVectorWithX:40.f y:0.f];
    [layerAnimation21 rotateByAngle:-M_PI_4 aboutVectorWithX:0.f y:1.f z:0.f];
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    animationStep1.tag = @"step2";
    [animationStep2 addLayerAnimation:layerAnimation21 forView:self.rectangleView1];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:self.rectangleView2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithObjects:animationStep1, animationStep2, nil]];
}

- (HLSAnimation *)animation12
{
    // Identity animation step with some duration
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    animationStep1.tag = @"step1";
    animationStep1.duration = 2.;
    return [HLSAnimation animationWithAnimationStep:animationStep1];
}

- (HLSAnimation *)animation13
{
    // Identity animation step with some duration
    HLSViewAnimationStep *animationStep1 = [HLSViewAnimationStep animationStep];
    animationStep1.tag = @"step1";
    animationStep1.duration = 2.;
    return [HLSAnimation animationWithAnimationStep:animationStep1];
}

// Other tests:
//   3) Mix layer & view animations
//   4) Complex pulse with several views
//   5) Cube & rotation: Setup initial step to position views, then rotate about PI

@end
