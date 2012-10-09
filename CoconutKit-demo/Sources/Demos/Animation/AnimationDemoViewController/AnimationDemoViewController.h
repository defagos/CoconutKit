//
//  AnimationDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/13/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface AnimationDemoViewController : HLSViewController <HLSAnimationDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
@private
    UIView *m_rectangleView1;
    UIView *m_rectangleView2;
    UIPickerView *m_animationPickerView;
    UIButton *m_playButton;
    UIButton *m_pauseButton;
    UIButton *m_cancelButton;
    UIButton *m_terminateButton;
    UISwitch *m_reverseSwitch;
    UISwitch *m_lockingUISwitch;
    UISwitch *m_loopingSwitch;
    UISwitch *m_animatedSwitch;
    UISlider *m_repeatCountSlider;
    UILabel *m_repeatCountLabel;
    UIView *m_animatedSettingsView;
    UISlider *m_delaySlider;
    UILabel *m_delayLabel;
    UISlider *m_durationSlider;
    UILabel *m_durationLabel;
    UISlider *m_startTimeSlider;
    UILabel *m_startTimeLabel;
    HLSAnimation *m_animation;
}

@property (nonatomic, retain) IBOutlet UIView *rectangleView1;
@property (nonatomic, retain) IBOutlet UIView *rectangleView2;
@property (nonatomic, retain) IBOutlet UIPickerView *animationPickerView;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *pauseButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet UIButton *terminateButton;
@property (nonatomic, retain) IBOutlet UISwitch *reverseSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *lockingUISwitch;
@property (nonatomic, retain) IBOutlet UISwitch *loopingSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *animatedSwitch;
@property (nonatomic, retain) IBOutlet UISlider *repeatCountSlider;
@property (nonatomic, retain) IBOutlet UILabel *repeatCountLabel;
@property (nonatomic, retain) IBOutlet UIView *animatedSettingsView;
@property (nonatomic, retain) IBOutlet UISlider *delaySlider;
@property (nonatomic, retain) IBOutlet UILabel *delayLabel;
@property (nonatomic, retain) IBOutlet UISlider *durationSlider;
@property (nonatomic, retain) IBOutlet UILabel *durationLabel;
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
