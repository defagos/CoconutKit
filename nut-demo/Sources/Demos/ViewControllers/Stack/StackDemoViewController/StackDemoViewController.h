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
@interface StackDemoViewController : HLSPlaceholderViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
@private
    UIButton *m_lifecycleTestSampleButton;
    UIButton *m_stretchableSampleButton;
    UIButton *m_fixedSizeSampleButton;
    UIButton *m_portraitOnlyButton;
    UIButton *m_landscapeOnlyButton;
    UIButton *m_orientationClonerButton;
    UIButton *m_containerCustomizationButton;
    UIButton *m_transparentButton;
    UIButton *m_popButton;
    UIButton *m_hideWithModalButton;
    UILabel *m_transitionLabel;
    UIPickerView *m_transitionPickerView;
    UILabel *m_stretchingContentLabel;
    UISwitch *m_stretchingContentSwitch;
    UILabel *m_forwardingPropertiesLabel;
    UISwitch *m_forwardingPropertiesSwitch;
}

@property (nonatomic, retain) IBOutlet UIButton *lifecycleTestSampleButton;
@property (nonatomic, retain) IBOutlet UIButton *stretchableSampleButton;
@property (nonatomic, retain) IBOutlet UIButton *fixedSizeSampleButton;
@property (nonatomic, retain) IBOutlet UIButton *portraitOnlyButton;
@property (nonatomic, retain) IBOutlet UIButton *landscapeOnlyButton;
@property (nonatomic, retain) IBOutlet UIButton *orientationClonerButton;
@property (nonatomic, retain) IBOutlet UIButton *containerCustomizationButton;
@property (nonatomic, retain) IBOutlet UIButton *transparentButton;
@property (nonatomic, retain) IBOutlet UIButton *popButton;
@property (nonatomic, retain) IBOutlet UIButton *hideWithModalButton;
@property (nonatomic, retain) IBOutlet UILabel *transitionLabel;
@property (nonatomic, retain) IBOutlet UIPickerView *transitionPickerView;
@property (nonatomic, retain) IBOutlet UILabel *stretchingContentLabel;
@property (nonatomic, retain) IBOutlet UISwitch *stretchingContentSwitch;
@property (nonatomic, retain) IBOutlet UILabel *forwardingPropertiesLabel;
@property (nonatomic, retain) IBOutlet UISwitch *forwardingPropertiesSwitch;

@end
