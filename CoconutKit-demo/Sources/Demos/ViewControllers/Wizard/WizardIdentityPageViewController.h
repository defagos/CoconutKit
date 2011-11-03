//
//  WizardIdentityPageViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/28/11.
//  Copyright 2011 Hortis. All rights reserved.
//

// Forward declarations
@class Customer;

@interface WizardIdentityPageViewController : HLSViewController <HLSReloadable, HLSTextFieldValidationDelegate, HLSValidable, UITextFieldDelegate> {
@private
    Customer *m_customer;
    UILabel *m_customerInformationLabel;
    UILabel *m_firstNameLabel;
    HLSTextField *m_firstNameTextField;
    UILabel *m_lastNameLabel;
    HLSTextField *m_lastNameTextField;
    UILabel *m_emailLabel;
    HLSTextField *m_emailTextField;
}

@property (nonatomic, retain) IBOutlet UILabel *customerInformationLabel;
@property (nonatomic, retain) IBOutlet UILabel *firstNameLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *firstNameTextField;
@property (nonatomic, retain) IBOutlet UILabel *lastNameLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *lastNameTextField;
@property (nonatomic, retain) IBOutlet UILabel *emailLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *emailTextField;

@end
