//
//  PlaceholderDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/14/11.
//  Copyright 2011 Hortis. All rights reserved.
//

// Forward declarations
@class HeavyViewController;

@interface PlaceholderDemoViewController : HLSPlaceholderViewController <HLSPlaceholderViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
@private
    UIButton *_heavyButton;
    UIPickerView *_transitionPickerView;
    UISwitch *_inTabBarControllerSwitch;
    UISwitch *_inNavigationControllerSwitch;
    UISwitch *_leftPlaceholderSwitch;
    UISwitch *_rightPlaceholderSwitch;
    HeavyViewController *_leftHeavyViewController;
    HeavyViewController *_rightHeavyViewController;
    UISegmentedControl *_autorotationModeSegmentedControl;
}

@property (nonatomic, retain) IBOutlet UIButton *heavyButton;
@property (nonatomic, retain) IBOutlet UIPickerView *transitionPickerView;
@property (nonatomic, retain) IBOutlet UISwitch *inTabBarControllerSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *inNavigationControllerSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *leftPlaceholderSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *rightPlaceholderSwitch;
@property (nonatomic, retain) IBOutlet UISegmentedControl *autorotationModeSegmentedControl;

- (IBAction)displayLifeCycleTest:(id)sender;
- (IBAction)displayContainmentTest:(id)sender;
- (IBAction)displayStretchable:(id)sender;
- (IBAction)displayFixedSize:(id)sender;
- (IBAction)displayHeavy:(id)sender;
- (IBAction)displayPortraitOnly:(id)sender;
- (IBAction)displayLandscapeOnly:(id)sender;
- (IBAction)remove:(id)sender;
- (IBAction)hideWithModal:(id)sender;
- (IBAction)togglePlaceholder:(id)sender;
- (IBAction)changeAutorotationMode:(id)sender;

- (IBAction)testResponderChain:(id)sender;

- (IBAction)navigateForwardNonAnimated:(id)sender;
- (IBAction)navigateBackNonAnimated:(id)sender;

@end
