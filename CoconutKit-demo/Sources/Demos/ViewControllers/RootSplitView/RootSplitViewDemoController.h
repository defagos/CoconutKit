//
//  RootSplitViewDemoController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 10/29/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface RootSplitViewDemoController : HLSViewController {
@private
    UISwitch *m_portraitSwitch;
    UISwitch *m_landscapeRightSwitch;
    UISwitch *m_landscapeLeftSwitch;
    UISwitch *m_portraitUpsideDownSwitch;
    UIView *m_autorotationBackgroundView;
    UISegmentedControl *m_autorotationModeSegmentedControl;
}

@property (nonatomic, retain) IBOutlet UISwitch *portraitSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *landscapeRightSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *landscapeLeftSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *portraitUpsideDownSwitch;
@property (nonatomic, retain) IBOutlet UIView *autorotationBackgroundView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *autorotationModeSegmentedControl;

- (IBAction)hideWithModal:(id)sender;
- (IBAction)changeAutorotationMode:(id)sender;

@end
