//
//  WizardAddressPageViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 21.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

// Forward declarations
@class Person;

@interface WizardAddressPageViewController : HLSViewController <HLSReloadable, HLSTextFieldValidationDelegate, HLSValidable, UITextFieldDelegate> {
@private
    Person *m_person;
    UILabel *m_streetLabel;
    HLSTextField *m_streetTextField;
    UILabel *m_cityLabel;
    HLSTextField *m_cityTextField;
    UILabel *m_stateLabel;
    HLSTextField *m_stateTextField;
    UILabel *m_countryLabel;
    HLSTextField *m_countryTextField;
    UIButton *m_resetButton;
}

@property (nonatomic, retain) IBOutlet UILabel *streetLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *streetTextField;
@property (nonatomic, retain) IBOutlet UILabel *cityLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *cityTextField;
@property (nonatomic, retain) IBOutlet UILabel *stateLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *stateTextField;
@property (nonatomic, retain) IBOutlet UILabel *countryLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *countryTextField;
@property (nonatomic, retain) IBOutlet UIButton *resetButton;

- (IBAction)reset:(id)sender;

@end
