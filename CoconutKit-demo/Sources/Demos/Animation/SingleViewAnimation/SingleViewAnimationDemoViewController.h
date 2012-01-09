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
    UISwitch *m_animatedSwitch;
    UISwitch *m_blockingSwitch;
    HLSAnimation *m_animation;
    HLSAnimation *m_reverseAnimation;
}

@property (nonatomic, retain) IBOutlet UIView *rectangleView;
@property (nonatomic, retain) IBOutlet UIButton *playForwardButton;
@property (nonatomic, retain) IBOutlet UIButton *playBackwardButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet UISwitch *animatedSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *blockingSwitch;

- (IBAction)playForwardButtonClicked:(id)sender;
- (IBAction)playBackwardButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;

@end
