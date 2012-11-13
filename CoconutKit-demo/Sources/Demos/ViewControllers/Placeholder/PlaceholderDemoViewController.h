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
    UIButton *m_heavyButton;
    UIPickerView *m_transitionPickerView;
    UISwitch *m_inTabBarControllerSwitch;
    UISwitch *m_inNavigationControllerSwitch;
    UISwitch *m_leftPlaceholderSwitch;
    UISwitch *m_rightPlaceholderSwitch;
    HeavyViewController *m_leftHeavyViewController;
    HeavyViewController *m_rightHeavyViewController;
    UISwitch *m_involvingChildrenForAutorotationSwitch;
}

@property (nonatomic, retain) IBOutlet UIButton *heavyButton;
@property (nonatomic, retain) IBOutlet UIPickerView *transitionPickerView;
@property (nonatomic, retain) IBOutlet UISwitch *inTabBarControllerSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *inNavigationControllerSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *leftPlaceholderSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *rightPlaceholderSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *involvingChildrenForAutorotationSwitch;

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
- (IBAction)toggleInvolvingChildrenForAutorotation:(id)sender;

- (IBAction)testResponderChain:(id)sender;

- (IBAction)navigateForwardNonAnimated:(id)sender;
- (IBAction)navigateBackNonAnimated:(id)sender;

@end
