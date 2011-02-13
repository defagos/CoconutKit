//
//  SingleViewAnimationDemoViewController.h
//  nut-demo
//
//  Created by Samuel Défago on 2/13/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface SingleViewAnimationDemoViewController : HLSViewController <HLSAnimationDelegate> {
@private
    UIView *m_rectangleView;
    UIButton *m_playForwardButton;
    UIButton *m_playBackwardButton;
    HLSAnimation *m_animation;
}

@property (nonatomic, retain) IBOutlet UIView *rectangleView;
@property (nonatomic, retain) IBOutlet UIButton *playForwardButton;
@property (nonatomic, retain) IBOutlet UIButton *playBackwardButton;

@end
