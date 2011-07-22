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
}

@property (nonatomic, retain) IBOutlet UIButton *lifecycleTestSampleButton;

@end
