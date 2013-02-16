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
    Person *_person;
    HLSTextField *_firstNameTextField;
    UILabel *_firstNameErrorLabel;
    HLSTextField *_lastNameTextField;
    UILabel *_lastNameErrorLabel;
    HLSTextField *_emailTextField;
    UILabel *_emailErrorLabel;
    UILabel *_birthdateLabel;
    HLSTextField *_birthdateTextField;
    UILabel *_birthdateErrorLabel;
    HLSTextField *_nbrChildrenTextField;
    UILabel *_nbrChildrenErrorLabel;
    NSDateFormatter *_dateFormatter;
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
