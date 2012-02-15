//
//  PlaceholderDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/14/11.
//  Copyright 2011 Hortis. All rights reserved.
//

// Forward declarations
@class HeavyViewController;

@interface PlaceholderDemoViewController : HLSPlaceholderViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
@private
    UIPickerView *m_transitionPickerView;
    UISwitch *m_inTabBarControllerSwitch;
    UISwitch *m_inNavigationControllerSwitch;
    UISwitch *m_forwardingPropertiesSwitch;
    HeavyViewController *m_heavyViewController;
}

@property (nonatomic, retain) IBOutlet UIPickerView *transitionPickerView;
@property (nonatomic, retain) IBOutlet UISwitch *inTabBarControllerSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *inNavigationControllerSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *forwardingPropertiesSwitch;

- (IBAction)displayLifeCycleTest:(id)sender;
- (IBAction)displayStretchable:(id)sender;
- (IBAction)displayFixedSize:(id)sender;
- (IBAction)displayHeavy:(id)sender;
- (IBAction)displayPortraitOnly:(id)sender;
- (IBAction)displayLandscapeOnly:(id)sender;
- (IBAction)remove:(id)sender;
- (IBAction)hideWithModal:(id)sender;
- (IBAction)displayOrientationCloner:(id)sender;
- (IBAction)displayContainerCustomization:(id)sender;
- (IBAction)toggleForwardingProperties:(id)sender;

@end
