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
    UIButton *m_resetButton;
    UIButton *m_playForwardButton;
    UIButton *m_playBackwardButton;
    UIButton *m_pauseButton;
    UIButton *m_cancelButton;
    UIButton *m_terminateButton;
    UISwitch *m_animatedSwitch;
    UISwitch *m_lockingUISwitch;
    UISwitch *m_delayedSwitch;
    UISwitch *m_overrideDurationSwitch;
    UISwitch *m_loopingSwitch;
    UISlider *m_repeatCountSlider;
    UILabel *m_repeatCountLabel;
    HLSAnimation *m_animation;
}

@property (nonatomic, retain) IBOutlet UIView *rectangleView1;
@property (nonatomic, retain) IBOutlet UIView *rectangleView2;
@property (nonatomic, retain) IBOutlet UIPickerView *animationPickerView;
@property (nonatomic, retain) IBOutlet UIButton *resetButton;
@property (nonatomic, retain) IBOutlet UIButton *playForwardButton;
@property (nonatomic, retain) IBOutlet UIButton *playBackwardButton;
@property (nonatomic, retain) IBOutlet UIButton *pauseButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet UIButton *terminateButton;
@property (nonatomic, retain) IBOutlet UISwitch *animatedSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *lockingUISwitch;
@property (nonatomic, retain) IBOutlet UISwitch *delayedSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *overrideDurationSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *loopingSwitch;
@property (nonatomic, retain) IBOutlet UISlider *repeatCountSlider;
@property (nonatomic, retain) IBOutlet UILabel *repeatCountLabel;

- (IBAction)reset:(id)sender;
- (IBAction)playForward:(id)sender;
- (IBAction)playBackward:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)terminate:(id)sender;
- (IBAction)repeatCountChanged:(id)sender;

@end
