//
//  PlaceholderDemoViewController.h
//  nut-demo
//
//  Created by Samuel Défago on 2/14/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface PlaceholderDemoViewController : HLSPlaceholderViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
@private
    UIButton *m_autoresizingSampleButton;
    UIButton *m_fixedSampleButton;
    UIButton *m_heavySampleButton;
    UIButton *m_portraitOnlyButton;
    UIButton *m_landscapeOnlyButton;
    UIButton *m_orientationClonerButton;
    UILabel *m_transitionLabel;
    UIPickerView *m_transitionPickerView;
    UILabel *m_adjustingInsetLabel;
    UISwitch *m_adjustingInsetSwitch;
}

@property (nonatomic, retain) IBOutlet UIButton *autoresizingSampleButton;
@property (nonatomic, retain) IBOutlet UIButton *fixedSampleButton;
@property (nonatomic, retain) IBOutlet UIButton *heavySampleButton;
@property (nonatomic, retain) IBOutlet UIButton *portraitOnlyButton;
@property (nonatomic, retain) IBOutlet UIButton *landscapeOnlyButton;
@property (nonatomic, retain) IBOutlet UIButton *orientationClonerButton;
@property (nonatomic, retain) IBOutlet UILabel *transitionLabel;
@property (nonatomic, retain) IBOutlet UIPickerView *transitionPickerView;
@property (nonatomic, retain) IBOutlet UILabel *adjustingInsetLabel;
@property (nonatomic, retain) IBOutlet UISwitch *adjustingInsetSwitch;

@end
