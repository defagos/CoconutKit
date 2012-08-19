//
//  WizardIdentityPageViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/28/11.
//  Copyright 2011 Hortis. All rights reserved.
//

// Forward declarations
@class Person;

@interface WizardIdentityPageViewController : HLSViewController <HLSTextFieldValidationDelegate, HLSValidable, UITextFieldDelegate> {
@private
    Person *m_person;
    HLSTextField *m_firstNameTextField;
    UILabel *m_firstNameErrorLabel;
    HLSTextField *m_lastNameTextField;
    UILabel *m_lastNameErrorLabel;
    HLSTextField *m_emailTextField;
    UILabel *m_emailErrorLabel;
    UILabel *m_birthdateLabel;
    HLSTextField *m_birthdateTextField;
    UILabel *m_birthdateErrorLabel;
    HLSTextField *m_nbrChildrenTextField;
    UILabel *m_nbrChildrenErrorLabel;
    NSDateFormatter *m_dateFormatter;
}

@property (nonatomic, retain) IBOutlet HLSTextField *firstNameTextField;
@property (nonatomic, retain) IBOutlet UILabel *firstNameErrorLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *lastNameTextField;
@property (nonatomic, retain) IBOutlet UILabel *lastNameErrorLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *emailTextField;
@property (nonatomic, retain) IBOutlet UILabel *emailErrorLabel;
@property (nonatomic, retain) IBOutlet UILabel *birthdateLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *birthdateTextField;
@property (nonatomic, retain) IBOutlet UILabel *birthdateErrorLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *nbrChildrenTextField;
@property (nonatomic, retain) IBOutlet UILabel *nbrChildrenErrorLabel;

- (IBAction)resetModel:(id)sender;
- (IBAction)resetTextFields:(id)sender;

@end
