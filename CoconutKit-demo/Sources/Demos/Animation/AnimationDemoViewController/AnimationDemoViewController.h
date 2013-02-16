//
//  AnimationDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/13/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface AnimationDemoViewController : HLSViewController <HLSAnimationDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
@private
    UIView *_rectangleView1;
    UIView *_rectangleView2;
    UIPickerView *_animationPickerView;
    UIButton *_playButton;
    UIButton *_pauseButton;
    UIButton *_cancelButton;
    UIButton *_terminateButton;
    UIView *_settingsView;
    UISwitch *_reverseSwitch;
    UISwitch *_lockingUISwitch;
    UISwitch *_loopingSwitch;
    UISwitch *_animatedSwitch;
    UISlider *_repeatCountSlider;
    UILabel *_repeatCountLabel;
    UIView *_animatedSettingsView;
    UISlider *_durationSlider;
    UILabel *_durationLabel;
    UIView *_delayBackgroundView;
    UISlider *_delaySlider;
    UILabel *_delayLabel;
    UIView *_startTimeBackgroundView;
    UISlider *_startTimeSlider;
    UILabel *_startTimeLabel;
    HLSAnimation *_animation;
}

@property (nonatomic, retain) IBOutlet UIView *rectangleView1;
@property (nonatomic, retain) IBOutlet UIView *rectangleView2;
@property (nonatomic, retain) IBOutlet UIPickerView *animationPickerView;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *pauseButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet UIButton *terminateButton;
@property (nonatomic, retain) IBOutlet UIView *settingsView;
@property (nonatomic, retain) IBOutlet UISwitch *reverseSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *lockingUISwitch;
@property (nonatomic, retain) IBOutlet UISwitch *loopingSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *animatedSwitch;
@property (nonatomic, retain) IBOutlet UISlider *repeatCountSlider;
@property (nonatomic, retain) IBOutlet UILabel *repeatCountLabel;
@property (nonatomic, retain) IBOutlet UIView *animatedSettingsView;
@property (nonatomic, retain) IBOutlet UISlider *durationSlider;
@property (nonatomic, retain) IBOutlet UILabel *durationLabel;
@property (nonatomic, retain) IBOutlet UIView *delayBackgroundView;
@property (nonatomic, retain) IBOutlet UISlider *delaySlider;
@property (nonatomic, retain) IBOutlet UILabel *delayLabel;
@property (nonatomic, retain) IBOutlet UIView *startTimeBackgroundView;
@property (nonatomic, retain) IBOutlet UISlider *startTimeSlider;
@property (nonatomic, retain) IBOutlet UILabel *startTimeLabel;

- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)terminate:(id)sender;
- (IBAction)toggleReverse:(id)sender;
- (IBAction)toggleLooping:(id)sender;
- (IBAction)toggleAnimated:(id)sender;
- (IBAction)delayChanged:(id)sender;
- (IBAction)durationChanged:(id)sender;
- (IBAction)repeatCountChanged:(id)sender;
- (IBAction)startTimeChanged:(id)sender;

@end
