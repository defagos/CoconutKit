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
    UILabel *m_lastNameLabel;
    HLSTextField *m_lastNameTextField;
    UILabel *m_emailLabel;
    HLSTextField *m_emailTextField;
    UILabel *m_birthdateLabel;
    HLSTextField *m_birthdateTextField;
    UILabel *m_nbrChildrenLabel;
    HLSTextField *m_nbrChildrenTextField;
}

@property (nonatomic, retain) IBOutlet UILabel *firstNameLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *firstNameTextField;
@property (nonatomic, retain) IBOutlet UILabel *lastNameLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *lastNameTextField;
@property (nonatomic, retain) IBOutlet UILabel *emailLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *emailTextField;
@property (nonatomic, retain) IBOutlet UILabel *birthdateLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *birthdateTextField;
@property (nonatomic, retain) IBOutlet UILabel *nbrChildrenLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *nbrChildrenTextField;

@end
