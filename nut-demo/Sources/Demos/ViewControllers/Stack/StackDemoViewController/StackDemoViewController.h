//
//  StackDemoViewController.h
//  nut-demo
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Designated initializer: init
 */
@interface StackDemoViewController : HLSPlaceholderViewController {
@private
    UIButton *m_lifecycleTestSampleButton;
    UIButton *m_popButton;
    UIButton *m_hideWithModalButton;
}

@property (nonatomic, retain) IBOutlet UIButton *lifecycleTestSampleButton;
@property (nonatomic, retain) IBOutlet UIButton *popButton;
@property (nonatomic, retain) IBOutlet UIButton *hideWithModalButton;

@end
