//
//  MultipleViewsAnimationDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/13/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface MultipleViewsAnimationDemoViewController : HLSViewController <HLSAnimationDelegate> {
@private
    UIView *m_rectangleView1;
    UIView *m_rectangleView2;
    UIView *m_rectangleView3;
    UIView *m_rectangleView4;
    UIButton *m_playForwardButton;
    UIButton *m_playBackwardButton;
    UIButton *m_cancelButton;
    UIButton *m_terminateButton;
    UISwitch *m_animatedSwitch;
    UISwitch *m_blockingSwitch;
    HLSAnimation *m_animation;
    HLSAnimation *m_reverseAnimation;
}

@property (nonatomic, retain) IBOutlet UIView *rectangleView1;
@property (nonatomic, retain) IBOutlet UIView *rectangleView2;
@property (nonatomic, retain) IBOutlet UIView *rectangleView3;
@property (nonatomic, retain) IBOutlet UIView *rectangleView4;
@property (nonatomic, retain) IBOutlet UIButton *playForwardButton;
@property (nonatomic, retain) IBOutlet UIButton *playBackwardButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet UIButton *terminateButton;
@property (nonatomic, retain) IBOutlet UISwitch *animatedSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *blockingSwitch;

- (IBAction)playForward:(id)sender;
- (IBAction)playBackward:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)terminate:(id)sender;

@end
