//
//  RootNavigationDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 10/29/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface RootNavigationDemoViewController : HLSViewController {
@private
    UISwitch *_portraitSwitch;
    UISwitch *_landscapeRightSwitch;
    UISwitch *_landscapeLeftSwitch;
    UISwitch *_portraitUpsideDownSwitch;
    UISegmentedControl *_autorotationModeSegmentedControl;
}

@property (nonatomic, retain) IBOutlet UISwitch *portraitSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *landscapeRightSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *landscapeLeftSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *portraitUpsideDownSwitch;
@property (nonatomic, retain) IBOutlet UISegmentedControl *autorotationModeSegmentedControl;

- (IBAction)push:(id)sender;
- (IBAction)pop:(id)sender;
- (IBAction)hideWithModal:(id)sender;
- (IBAction)changeAutorotationMode:(id)sender;

@end
