//
//  SingleViewAnimationDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/13/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface SingleViewAnimationDemoViewController : HLSViewController <HLSAnimationDelegate> {
@private
    UIView *m_rectangleView;
    UIButton *m_playForwardButton;
    UIButton *m_playBackwardButton;
    UIButton *m_cancelButton;
    UIButton *m_terminateButton;
    UISwitch *m_animatedSwitch;
    UISwitch *m_blockingSwitch;
    UISwitch *m_delayedSwitch;
    HLSAnimation *m_animation;
    HLSAnimation *m_reverseAnimation;
}

@property (nonatomic, retain) IBOutlet UIView *rectangleView;
@property (nonatomic, retain) IBOutlet UIButton *playForwardButton;
@property (nonatomic, retain) IBOutlet UIButton *playBackwardButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet UIButton *terminateButton;
@property (nonatomic, retain) IBOutlet UISwitch *animatedSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *blockingSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *delayedSwitch;

- (IBAction)playForward:(id)sender;
- (IBAction)playBackward:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)terminate:(id)sender;

@end
