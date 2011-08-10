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
    UILabel *m_animatedLabel;
    UISwitch *m_animatedSwitch;
    HLSAnimation *m_animation;
}

@property (nonatomic, retain) IBOutlet UIView *rectangleView1;
@property (nonatomic, retain) IBOutlet UIView *rectangleView2;
@property (nonatomic, retain) IBOutlet UIView *rectangleView3;
@property (nonatomic, retain) IBOutlet UIView *rectangleView4;
@property (nonatomic, retain) IBOutlet UIButton *playForwardButton;
@property (nonatomic, retain) IBOutlet UIButton *playBackwardButton;
@property (nonatomic, retain) IBOutlet UILabel *animatedLabel;
@property (nonatomic, retain) IBOutlet UISwitch *animatedSwitch;

@end
