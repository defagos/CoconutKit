//
//  WizardIdentityPageViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/28/11.
//  Copyright 2011 Hortis. All rights reserved.
//

// Forward declarations
@class Person;

@interface WizardIdentityPageViewController : HLSViewController <HLSReloadable, HLSTextFieldValidationDelegate, HLSValidable, UITextFieldDelegate> {
@private
    Person *m_person;
    UILabel *m_firstNameLabel;
    HLSTextField *m_firstNameTextField;
    UILabel *m_firstNameErrorLabel;
    UILabel *m_lastNameLabel;
    HLSTextField *m_lastNameTextField;
    UILabel *m_lastNameErrorLabel;
    UILabel *m_emailLabel;
    HLSTextField *m_emailTextField;
    UILabel *m_emailErrorLabel;
    UILabel *m_birthdateLabel;
    HLSTextField *m_birthdateTextField;
    UILabel *m_birthdateErrorLabel;
    UILabel *m_nbrChildrenLabel;
    HLSTextField *m_nbrChildrenTextField;
    UILabel *m_nbrChildrenErrorLabel;
    UIButton *m_resetModelButton;
    UIButton *m_resetTextFieldsButton;
    NSDateFormatter *m_dateFormatter;
}

@property (nonatomic, retain) IBOutlet UILabel *firstNameLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *firstNameTextField;
@property (nonatomic, retain) IBOutlet UILabel *firstNameErrorLabel;
@property (nonatomic, retain) IBOutlet UILabel *lastNameLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *lastNameTextField;
@property (nonatomic, retain) IBOutlet UILabel *lastNameErrorLabel;
@property (nonatomic, retain) IBOutlet UILabel *emailLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *emailTextField;
@property (nonatomic, retain) IBOutlet UILabel *emailErrorLabel;
@property (nonatomic, retain) IBOutlet UILabel *birthdateLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *birthdateTextField;
@property (nonatomic, retain) IBOutlet UILabel *birthdateErrorLabel;
@property (nonatomic, retain) IBOutlet UILabel *nbrChildrenLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *nbrChildrenTextField;
@property (nonatomic, retain) IBOutlet UILabel *nbrChildrenErrorLabel;
@property (nonatomic, retain) IBOutlet UIButton *resetModelButton;
@property (nonatomic, retain) IBOutlet UIButton *resetTextFieldsButton;

- (IBAction)resetModel:(id)sender;
- (IBAction)resetTextFields:(id)sender;

@end
