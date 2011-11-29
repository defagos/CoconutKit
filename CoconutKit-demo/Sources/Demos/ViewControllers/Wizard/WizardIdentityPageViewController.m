//
//  WizardIdentityPageViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/28/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "WizardIdentityPageViewController.h"

#import "Person.h"

@interface WizardIdentityPageViewController ()

@property (nonatomic, retain) Person *person;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

@end

@implementation WizardIdentityPageViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super initWithNibName:[self className] bundle:nil])) {
        // Only one person in the DB. If does not exist yet, create it
        Person *person = [[Person allObjects] firstObject];
        if (! person) {
            person = [Person insert];
        }
        self.person = person;
    }
    return self;
}

- (void)dealloc
{
    self.person = nil;
    self.dateFormatter = nil;
    
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.firstNameLabel = nil;
    self.firstNameTextField = nil;
    self.lastNameLabel = nil;
    self.lastNameTextField = nil;
    self.emailLabel = nil;
    self.emailTextField = nil;
    self.birthdateLabel = nil;
    self.birthdateTextField = nil;
    self.nbrChildrenLabel = nil;
    self.nbrChildrenTextField = nil;
    self.resetModelButton = nil;
    self.resetTextFieldsButton = nil;
}

#pragma mark Accessors and mutators

@synthesize person = m_person;

- (void)setPerson:(Person *)person
{
    if (m_person == person) {
        return;
    }
    
    [m_person release];
    m_person = [person retain];
    
    [self reloadData];
}

@synthesize firstNameLabel = m_firstNameLabel;

@synthesize firstNameTextField = m_firstNameTextField;

@synthesize lastNameLabel = m_lastNameLabel;

@synthesize lastNameTextField = m_lastNameTextField;

@synthesize emailLabel = m_emailLabel;

@synthesize emailTextField = m_emailTextField;

@synthesize birthdateLabel = m_birthdateLabel;

@synthesize birthdateTextField = m_birthdateTextField;

@synthesize nbrChildrenLabel = m_nbrChildrenLabel;

@synthesize nbrChildrenTextField = m_nbrChildrenTextField;

@synthesize resetModelButton = m_resetModelButton;

@synthesize resetTextFieldsButton = m_resetTextFieldsButton;

@synthesize dateFormatter = m_dateFormatter;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
    
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.birthdateTextField.delegate = self;
    self.nbrChildrenTextField.delegate = self;
    
    [self reloadData];
}

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{    
    static NSNumberFormatter *s_numberFormatter = nil;
    if (! s_numberFormatter) {
        s_numberFormatter = [[NSNumberFormatter alloc] init];
        [s_numberFormatter setPositiveFormat:@"#0.#"];
        [s_numberFormatter setNegativeFormat:@"-#0.#"];
    }
    
    [self.firstNameTextField bindToManagedObject:self.person
                                       fieldName:@"firstName" 
                                       formatter:nil
                              validationDelegate:self];
    [self.lastNameTextField bindToManagedObject:self.person
                                      fieldName:@"lastName"
                                      formatter:nil 
                             validationDelegate:self];
    [self.emailTextField bindToManagedObject:self.person
                                   fieldName:@"email" 
                                   formatter:nil 
                          validationDelegate:self];
    [self.emailTextField setCheckingOnChange:YES];
    [self.birthdateTextField bindToManagedObject:self.person
                                       fieldName:@"birthdate"
                                       formatter:self.dateFormatter 
                              validationDelegate:self];
    [self.birthdateTextField setCheckingOnChange:YES];
    [self.nbrChildrenTextField bindToManagedObject:self.person 
                                         fieldName:@"nbrChildren"
                                         formatter:s_numberFormatter 
                                validationDelegate:self];
}

#pragma mark HLSValidable protocol implementation

- (BOOL)validate
{
    return [self checkTextFields];
}

#pragma mark UITextFieldDelegate protocol implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark HLSTextFieldValidationDelegate protocol implementation

- (void)textFieldDidFailFormatting:(UITextField *)textField
{
    textField.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5f];
}

- (void)textFieldDidPassValidation:(UITextField *)textField
{
    textField.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5f];
}

- (void)textField:(UITextField *)textField didFailValidationWithError:(NSError *)error
{
    textField.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5f];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.firstNameLabel.text = NSLocalizedString(@"First Name", @"First Name");
    self.lastNameLabel.text = NSLocalizedString(@"Last Name", @"Last Name");
    self.emailLabel.text = NSLocalizedString(@"E-mail", @"E-mail");
    self.birthdateLabel.text = [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"Birthdate", @"Birthdate"), NSLocalizedString(@"yyyy/MM/dd", @"yyyy/MM/dd")];
    self.nbrChildrenLabel.text = NSLocalizedString(@"Number of children", @"Number of children");
    [self.resetModelButton setTitle:NSLocalizedString(@"Reset model fields", @"Reset model fields") forState:UIControlStateNormal];
    [self.resetTextFieldsButton setTitle:NSLocalizedString(@"Reset text fields", @"Reset text fields") forState:UIControlStateNormal];
    
    // The date formatter is also localized!
    // TODO: Does not work yet. Try to switch languages!
    self.dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [self.dateFormatter setDateFormat:NSLocalizedString(@"yyyy/MM/dd", @"yyyy/MM/dd")];
}

#pragma mark Event callbacks

- (IBAction)resetModel:(id)sender
{
    // Reset the model programmatically. This shows that the text fields are updated accordingly
    self.person.firstName = nil;
    self.person.lastName = nil;
    self.person.firstName = nil;
    self.person.lastName = nil;
    self.person.email = nil;
    self.person.birthdate = nil;
    self.person.nbrChildrenValue = 0;
}

- (IBAction)resetTextFields:(id)sender
{
    // Reset text fields programmatically. This shows that the model is updated accordingly
    self.firstNameTextField.text = nil;
    self.lastNameTextField.text = nil;
    self.emailTextField.text = nil;
    self.birthdateTextField.text = nil;
    self.nbrChildrenTextField.text = @"0";
}

@end
