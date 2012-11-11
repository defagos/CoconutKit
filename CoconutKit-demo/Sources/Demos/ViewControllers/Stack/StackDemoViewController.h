//
//  StackDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Designated initializer: init
 */
@interface StackDemoViewController : HLSPlaceholderViewController <HLSStackControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
@private
    UIButton *m_popoverButton;
    UIPickerView *m_transitionPickerView;
    UISegmentedControl *m_autorotationModeSegmentedControl;
    UISwitch *m_inTabBarControllerSwitch;
    UISwitch *m_inNavigationControllerSwitch;
    UISwitch *m_animatedSwitch;
    UISlider *m_indexSlider;
    UILabel *m_insertionIndexLabel;
    UILabel *m_removalIndexLabel;
    UIPopoverController *m_popoverController;
}

@property (nonatomic, retain) IBOutlet UIButton *popoverButton;
@property (nonatomic, retain) IBOutlet UIPickerView *transitionPickerView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *autorotationModeSegmentedControl;
@property (nonatomic, retain) IBOutlet UISwitch *inTabBarControllerSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *inNavigationControllerSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *animatedSwitch;
@property (nonatomic, retain) IBOutlet UISlider *indexSlider;
@property (nonatomic, retain) IBOutlet UILabel *insertionIndexLabel;
@property (nonatomic, retain) IBOutlet UILabel *removalIndexLabel;

- (IBAction)displayLifeCycleTest:(id)sender;
- (IBAction)displayContainmentTest:(id)sender;
- (IBAction)displayStretchable:(id)sender;
- (IBAction)displayFixedSize:(id)sender;
- (IBAction)displayHeavy:(id)sender;
- (IBAction)displayPortraitOnly:(id)sender;
- (IBAction)displayLandscapeOnly:(id)sender;
- (IBAction)hideWithModal:(id)sender;
- (IBAction)displayTransparent:(id)sender;
- (IBAction)testInModal:(id)sender;
- (IBAction)testInPopover:(id)sender;

- (IBAction)pop:(id)sender;
- (IBAction)popToRoot:(id)sender;
- (IBAction)popThree:(id)sender;

- (IBAction)testResponderChain:(id)sender;

- (IBAction)changeAutorotationMode:(id)sender;

- (IBAction)indexChanged:(id)sender;

- (IBAction)navigateForwardNonAnimated:(id)sender;
- (IBAction)navigateBackNonAnimated:(id)sender;

@end
