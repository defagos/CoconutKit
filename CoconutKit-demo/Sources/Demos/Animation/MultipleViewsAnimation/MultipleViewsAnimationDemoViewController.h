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
    UILabel *m_animatedLabel;
    UISwitch *m_animatedSwitch;
    UILabel *m_blockingLabel;
    UISwitch *m_blockingSwitch;
    UILabel *m_resizingLabel;
    UISwitch *m_resizingSwitch;
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
@property (nonatomic, retain) IBOutlet UILabel *animatedLabel;
@property (nonatomic, retain) IBOutlet UISwitch *animatedSwitch;
@property (nonatomic, retain) IBOutlet UILabel *blockingLabel;
@property (nonatomic, retain) IBOutlet UISwitch *blockingSwitch;
@property (nonatomic, retain) IBOutlet UILabel *resizingLabel;
@property (nonatomic, retain) IBOutlet UISwitch *resizingSwitch;

@end
