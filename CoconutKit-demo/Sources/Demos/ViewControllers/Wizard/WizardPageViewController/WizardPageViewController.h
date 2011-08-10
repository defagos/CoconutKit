//
//  WizardPageViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/28/11.
//  Copyright 2011 Hortis. All rights reserved.
//

// Forward declarations
@class Customer;

@interface WizardPageViewController : HLSViewController <HLSValidable, UITextFieldDelegate> {
@private
    Customer *m_customer;
    UILabel *m_customerInformationLabel;
    UILabel *m_firstNameLabel;
    HLSTextField *m_firstNameTextField;
    UILabel *m_lastNameLabel;
    HLSTextField *m_lastNameTextField;
    UILabel *m_emailLabel;
    HLSTextField *m_emailTextField;
    UILabel *m_streetLabel;
    HLSTextField *m_streetTextField;
    UILabel *m_cityLabel;
    HLSTextField *m_cityTextField;
    UILabel *m_stateLabel;
    HLSTextField *m_stateTextField;
    UILabel *m_countryLabel;
    HLSTextField *m_countryTextField;
}

@property (nonatomic, retain) IBOutlet UILabel *customerInformationLabel;
@property (nonatomic, retain) IBOutlet UILabel *firstNameLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *firstNameTextField;
@property (nonatomic, retain) IBOutlet UILabel *lastNameLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *lastNameTextField;
@property (nonatomic, retain) IBOutlet UILabel *emailLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *emailTextField;
@property (nonatomic, retain) IBOutlet UILabel *streetLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *streetTextField;
@property (nonatomic, retain) IBOutlet UILabel *cityLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *cityTextField;
@property (nonatomic, retain) IBOutlet UILabel *stateLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *stateTextField;
@property (nonatomic, retain) IBOutlet UILabel *countryLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *countryTextField;

@end
