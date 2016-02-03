//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "AnimationDemoViewController.h"

static const NSTimeInterval kAnimationIntrinsicDuration = -1.;

@interface AnimationDemoViewController ()

@property (nonatomic, strong) HLSAnimation *animation;

@property (nonatomic, weak) IBOutlet UIView *rectangleView1;
@property (nonatomic, weak) IBOutlet UIView *rectangleView2;
@property (nonatomic, weak) IBOutlet UIPickerView *animationPickerView;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *pauseButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *terminateButton;
@property (nonatomic, weak) IBOutlet UIView *settingsView;
@property (nonatomic, weak) IBOutlet UISwitch *reverseSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *lockingUISwitch;
@property (nonatomic, weak) IBOutlet UISwitch *loopingSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *animatedSwitch;
@property (nonatomic, weak) IBOutlet UISlider *repeatCountSlider;
@property (nonatomic, weak) IBOutlet UILabel *repeatCountLabel;
@property (nonatomic, weak) IBOutlet UIView *animatedSettingsView;
@property (nonatomic, weak) IBOutlet UISlider *durationSlider;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;
@property (nonatomic, weak) IBOutlet UIView *delayBackgroundView;
@property (nonatomic, weak) IBOutlet UISlider *delaySlider;
@property (nonatomic, weak) IBOutlet UILabel *delayLabel;
@property (nonatomic, weak) IBOutlet UIView *startTimeBackgroundView;
@property (nonatomic, weak) IBOutlet UISlider *startTimeSlider;
@property (nonatomic, weak) IBOutlet UILabel *startTimeLabel;

@end

@implementation AnimationDemoViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.animationPickerView.dataSource = self;
    self.animationPickerView.delegate = self;
    
    // Apply a perspective to sublayers
    CATransform3D sublayerTransform = self.view.layer.sublayerTransform;
    sublayerTransform.m34 = -1.f / 1000.f;
    
    [self calculateAnimation];
    [self updateUserInterface];
}

#pragma mark Orientation management

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Single view animation", nil);
}

#pragma mark Responding to parameter adjustment

- (void)updateUserInterface
{
    self.animatedSettingsView.hidden = ! self.animatedSwitch.on;
    self.delayBackgroundView.hidden = (self.startTimeSlider.value != 0.f);
    self.startTimeBackgroundView.hidden = (self.delaySlider.value != 0.f);
    
    self.delayLabel.text = [NSString stringWithFormat:@"%.2f", [self delay]];
    
    NSTimeInterval duration = [self duration];
    if (duration == kAnimationIntrinsicDuration) {
        self.durationLabel.text = @"-";
    }
    else {
        self.durationLabel.text = [NSString stringWithFormat:@"%.2f", [self duration]];
    }
    
    NSUInteger repeatCount = [self repeatCount];
    if (repeatCount == NSUIntegerMax) {
        self.repeatCountLabel.text = @"inf";
    }
    else {
        self.repeatCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)repeatCount];
    }
    
    // Adjust the start time to cover the whole animation
    self.startTimeSlider.maximumValue = [self totalDuration];
    
    self.startTimeLabel.text = [NSString stringWithFormat:@"%.2f", self.startTimeSlider.value];
    
    if (self.animation.playing) {
        self.playButton.hidden = ! self.animation.paused;
        self.pauseButton.hidden = self.animation.paused;
        self.cancelButton.hidden = NO;
        self.terminateButton.hidden = NO;
        self.settingsView.hidden = YES;
    }
    else {
        self.playButton.hidden = NO;
        self.pauseButton.hidden = YES;
        self.cancelButton.hidden = YES;
        self.terminateButton.hidden = YES;
        self.settingsView.hidden = NO;
    }
}

- (void)calculateAnimation
{
    NSUInteger animationIndex = [self.animationPickerView selectedRowInComponent:0] + 1;
    SEL selector = [self selectorForAnimationWithIndex:animationIndex];
    
    // Cannot use -performSelector here since the signature is not explicitly visible in the call for ARC to perform
    // correct memory management
    id (*methodImp)(id, SEL) = (id (*)(id, SEL))[self methodForSelector:selector];
    HLSAnimation *animation = methodImp(self, selector);
    
    __unused __weak HLSAnimation *weakAnimation = animation;
    animation.startBlock = ^(BOOL animated) {
        HLSLoggerInfo(@"Start block called for animation %@", weakAnimation.tag);
    };
    animation.completionBlock = ^(BOOL animated) {
        HLSLoggerInfo(@"Completion block called for animation %@", weakAnimation.tag);
    };
    
    animation.tag = [NSString stringWithFormat:@"animation%lu", (unsigned long)animationIndex];
    if (self.reverseSwitch.on) {
        animation = [animation reverseAnimation];
    }
    if (self.loopingSwitch.on) {
        animation = [animation loopAnimation];
    }
    if ([self duration] != kAnimationIntrinsicDuration) {
        animation = [animation animationWithDuration:[self duration]];
    }
    animation.delegate = self;
    animation.lockingUI = self.lockingUISwitch.on;
    
    self.animation = animation;
    
    // Reset the start time slider to a value which is always valid
    self.startTimeSlider.value = 0.f;
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated
{
    HLSLoggerInfo(@"Animation %@ will start, animated = %@, running = %@, playing = %@, started = %@, cancelling = %@, terminating = %@",
                  animation.tag, HLSStringFromBool(animated), HLSStringFromBool(animation.running), HLSStringFromBool(animation.playing),
                  HLSStringFromBool(animation.started), HLSStringFromBool(animation.cancelling), HLSStringFromBool(animation.terminating));
}

- (void)animation:(HLSAnimation *)animation didFinishStep:(HLSAnimationStep *)animationStep animated:(BOOL)animated
{
    HLSLoggerInfo(@"Step with tag %@ finished, animated = %@, running = %@, playing = %@, started = %@, cancelling = %@, terminating = %@",
                  animationStep.tag, HLSStringFromBool(animated), HLSStringFromBool(animation.running), HLSStringFromBool(animation.playing),
                  HLSStringFromBool(animation.started), HLSStringFromBool(animation.cancelling), HLSStringFromBool(animation.terminating));
}

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    HLSLoggerInfo(@"Animation %@ did stop, animated = %@, running = %@, playing = %@, started = %@, cancelling = %@, terminating = %@",
                  animation.tag, HLSStringFromBool(animated), HLSStringFromBool(animation.running), HLSStringFromBool(animation.playing),
                  HLSStringFromBool(animation.started), HLSStringFromBool(animation.cancelling), HLSStringFromBool(animation.terminating));
    [self updateUserInterface];
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
    return [NSString stringWithFormat:@"%ld", (long)row + 1];
}

#pragma mark UIPickerViewDelegate protocol implementation

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self calculateAnimation];
    [self updateUserInterface];
}

#pragma mark Event callbacks

- (IBAction)play:(id)sender
{
    if (self.animation.paused) {
        [self.animation resume];
    }
    else {
        if ([self delay] == 0.) {
            [self.animation playWithRepeatCount:[self repeatCount] afterDelay:[self delay]];
        }
        else if ([self startTime] != 0.) {
            [self.animation playWithStartTime:[self startTime] repeatCount:[self repeatCount]];
        }
        else {
            [self.animation playWithRepeatCount:[self repeatCount] animated:self.animatedSwitch.on];
        }
    }
    [self updateUserInterface];
}

- (IBAction)pause:(id)sender
{
    [self.animation pause];
    [self updateUserInterface];
}

- (IBAction)cancel:(id)sender
{
    [self.animation cancel];
    
    // We need to update the UI manually since the animation end callback is not called in such cases
    [self updateUserInterface];
}

- (IBAction)terminate:(id)sender
{
    [self.animation terminate];
}

- (IBAction)toggleReverse:(id)sender
{
    [self calculateAnimation];
    [self updateUserInterface];
}

- (IBAction)toggleLooping:(id)sender
{
    [self calculateAnimation];
    [self updateUserInterface];
}

- (IBAction)toggleAnimated:(id)sender
{
    [self updateUserInterface];
}

- (IBAction)delayChanged:(id)sender
{
    [self updateUserInterface];
}

- (IBAction)durationChanged:(id)sender
{
    [self calculateAnimation];
    [self updateUserInterface];
}

- (IBAction)repeatCountChanged:(id)sender
{
    [self updateUserInterface];
}

- (IBAction)startTimeChanged:(id)sender
{
    [self updateUserInterface];
}

#pragma mark Animations

- (SEL)selectorForAnimationWithIndex:(NSUInteger)index
{
    NSString *selectorName = [NSString stringWithFormat:@"animation%lu", (unsigned long)index];
    return NSSelectorFromString(selectorName);
}

- (NSTimeInterval)delay
{
    return self.delaySlider.value;
}

- (NSTimeInterval)duration
{
    if (self.durationSlider.value == self.durationSlider.maximumValue) {
        return kAnimationIntrinsicDuration;
    }
    else {
        return self.durationSlider.value;
    }
}

- (NSTimeInterval)totalDuration
{
    // Special case of infinitely repeating animations: Must limit the range so that the slider can still be used
    // conveniently
    if ([self repeatCount] == NSUIntegerMax) {
        return 5. * [self.animation duration];
    }
    else {
        return [self repeatCount] * [self.animation duration] + [self delay];
    }
}

- (NSUInteger)repeatCount
{
    if (self.repeatCountSlider.value == self.repeatCountSlider.maximumValue) {
        return NSUIntegerMax;
    }
    else {
        return roundf(self.repeatCountSlider.value);
    }
}

- (NSTimeInterval)startTime
{
    if (self.startTimeSlider.value == [self totalDuration]) {
        return self.startTimeSlider.value;
    }
    else {
        return self.startTimeSlider.value;
    }
}

- (HLSAnimation *)animation1
{
    // Layer translation, one view
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 translateByVectorWithX:100.f y:20.f];
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    animationStep1.completionBlock = ^(BOOL animated) {
        HLSLoggerDebug(@"Completion block called for step1");
    };
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
    // Layer animation made of several steps
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 translateByVectorWithX:200.f y:0.f];
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    animationStep1.tag = @"step1";
    [animationStep1 addLayerAnimation:layerAnimation11 forView:self.rectangleView1];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:self.rectangleView2];
    
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    [layerAnimation21 translateByVectorWithX:0.f y:50.f];
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    animationStep2.tag = @"step2";
    [animationStep2 addLayerAnimation:layerAnimation21 forView:self.rectangleView1];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:self.rectangleView2];
    
    HLSLayerAnimation *layerAnimation31 = [HLSLayerAnimation animation];
    [layerAnimation31 translateByVectorWithX:-200.f y:0.f];
    HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
    animationStep3.tag = @"step3";
    [animationStep3 addLayerAnimation:layerAnimation31 forView:self.rectangleView1];
    [animationStep3 addLayerAnimation:layerAnimation31 forView:self.rectangleView2];
    
    HLSLayerAnimation *layerAnimation41 = [HLSLayerAnimation animation];
    [layerAnimation41 translateByVectorWithX:0.f y:-50.f];
    HLSLayerAnimationStep *animationStep4 = [HLSLayerAnimationStep animationStep];
    animationStep4.tag = @"step4";
    [animationStep4 addLayerAnimation:layerAnimation41 forView:self.rectangleView1];
    [animationStep4 addLayerAnimation:layerAnimation41 forView:self.rectangleView2];
    
    return [HLSAnimation animationWithAnimationSteps:@[animationStep1, animationStep2, animationStep3, animationStep4]];
}

- (HLSAnimation *)animation10
{
    // View animation made of several steps
    HLSViewAnimation *viewAnimation11 = [HLSViewAnimation animation];
    [viewAnimation11 translateByVectorWithX:200.f y:0.f];
    HLSViewAnimationStep *animationStep1 = [HLSViewAnimationStep animationStep];
    animationStep1.tag = @"step1";
    [animationStep1 addViewAnimation:viewAnimation11 forView:self.rectangleView1];
    [animationStep1 addViewAnimation:viewAnimation11 forView:self.rectangleView2];
    
    HLSViewAnimation *viewAnimation21 = [HLSViewAnimation animation];
    [viewAnimation21 translateByVectorWithX:0.f y:50.f];
    HLSViewAnimationStep *animationStep2 = [HLSViewAnimationStep animationStep];
    animationStep2.tag = @"step2";
    [animationStep2 addViewAnimation:viewAnimation21 forView:self.rectangleView1];
    [animationStep2 addViewAnimation:viewAnimation21 forView:self.rectangleView2];
    
    HLSViewAnimation *viewAnimation31 = [HLSViewAnimation animation];
    [viewAnimation31 translateByVectorWithX:-200.f y:0.f];
    HLSViewAnimationStep *animationStep3 = [HLSViewAnimationStep animationStep];
    animationStep3.tag = @"step3";
    [animationStep3 addViewAnimation:viewAnimation31 forView:self.rectangleView1];
    [animationStep3 addViewAnimation:viewAnimation31 forView:self.rectangleView2];
    
    HLSViewAnimation *viewAnimation41 = [HLSViewAnimation animation];
    [viewAnimation41 translateByVectorWithX:0.f y:-50.f];
    HLSViewAnimationStep *animationStep4 = [HLSViewAnimationStep animationStep];
    animationStep4.tag = @"step4";
    [animationStep4 addViewAnimation:viewAnimation41 forView:self.rectangleView1];
    [animationStep4 addViewAnimation:viewAnimation41 forView:self.rectangleView2];
    
    return [HLSAnimation animationWithAnimationSteps:@[animationStep1, animationStep2, animationStep3, animationStep4]];
}

- (HLSAnimation *)animation11
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
    
    return [HLSAnimation animationWithAnimationSteps:@[animationStep1, animationStep2, animationStep3]];
}

- (HLSAnimation *)animation12
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
    
    return [HLSAnimation animationWithAnimationSteps:@[animationStep1, animationStep2]];
}

- (HLSAnimation *)animation13
{
    // Mixing UIView-based and Core Animation-based animation steps (NOT on the same views, otherwise the behavior
    // is undefined)
    HLSViewAnimation *viewAnimation11 = [HLSViewAnimation animation];
    [viewAnimation11 scaleWithXFactor:2.f yFactor:2.f];
    HLSViewAnimationStep *animationStep1 = [HLSViewAnimationStep animationStep];
    animationStep1.tag = @"step1";
    [animationStep1 addViewAnimation:viewAnimation11 forView:self.rectangleView1];
    
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    [layerAnimation21 rotateByAngle:M_PI_4 aboutVectorWithX:0.f y:1.f z:0.f];
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    animationStep2.tag = @"step2";
    [animationStep2 addLayerAnimation:layerAnimation21 forView:self.rectangleView2];
    
    HLSViewAnimation *viewAnimation31 = [HLSViewAnimation animation];
    [viewAnimation31 scaleWithXFactor:0.5f yFactor:1.f];
    HLSViewAnimationStep *animationStep3 = [HLSViewAnimationStep animationStep];
    animationStep3.tag = @"step3";
    [animationStep3 addViewAnimation:viewAnimation31 forView:self.rectangleView1];
    
    return [HLSAnimation animationWithAnimationSteps:@[animationStep1, animationStep2, animationStep3]];
}

- (HLSAnimation *)animation14
{
    // Empty animation. Also triggers willStart and didStop callbacks
    return [HLSAnimation animationWithAnimationStep:nil];
}

- (HLSAnimation *)animation15
{
    // Identity animation step with some duration
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    animationStep1.tag = @"step1";
    animationStep1.duration = 2.;
    return [HLSAnimation animationWithAnimationStep:animationStep1];
}

- (HLSAnimation *)animation16
{
    // Identity animation step with some duration
    HLSViewAnimationStep *animationStep1 = [HLSViewAnimationStep animationStep];
    animationStep1.tag = @"step1";
    animationStep1.duration = 2.;
    return [HLSAnimation animationWithAnimationStep:animationStep1];
}

@end
