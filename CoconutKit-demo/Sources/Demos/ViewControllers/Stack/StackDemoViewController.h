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
@interface StackDemoViewController : HLSPlaceholderViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
@private
    UIPickerView *m_transitionPickerView;
    UISwitch *m_forwardingPropertiesSwitch;
}

@property (nonatomic, retain) IBOutlet UIPickerView *transitionPickerView;
@property (nonatomic, retain) IBOutlet UISwitch *forwardingPropertiesSwitch;

- (IBAction)lifeCycleTestSampleButtonClicked:(id)sender;
- (IBAction)stretchableSampleButtonClicked:(id)sender;
- (IBAction)fixedSizeSampleButtonClicked:(id)sender;
- (IBAction)portraitOnlyButtonClicked:(id)sender;
- (IBAction)landscapeOnlyButtonClicked:(id)sender;
- (IBAction)hideWithModalButtonClicked:(id)sender;
- (IBAction)orientationClonerButtonClicked:(id)sender;
- (IBAction)containerCustomizationButtonClicked:(id)sender;
- (IBAction)transparentButtonClicked:(id)sender;
- (IBAction)testInModalButtonClicked:(id)sender;
- (IBAction)popButtonClicked:(id)sender;
- (IBAction)forwardingPropertiesSwitchValueChanged:(id)sender;

@end
