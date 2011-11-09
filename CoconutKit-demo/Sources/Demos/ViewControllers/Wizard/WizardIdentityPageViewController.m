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
    static NSDateFormatter *s_dateFormatter = nil;
    if (! s_dateFormatter) {
        s_dateFormatter = [[NSDateFormatter alloc] init];
        [s_dateFormatter setDateFormat:NSLocalizedString(@"yyyy/MM/dd", @"yyyy/MM/dd")];
    }
    
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
    [self.birthdateTextField bindToManagedObject:self.person
                                       fieldName:@"birthdate"
                                       formatter:s_dateFormatter 
                              validationDelegate:self];
    [self.nbrChildrenTextField bindToManagedObject:self.person 
                                         fieldName:@"nbrChildren"
                                         formatter:s_numberFormatter 
                                validationDelegate:self];
}

#pragma mark HLSValidable protocol implementation

- (BOOL)validate
{
    NSError *error = nil;
    return [self checkBoundManagedObjectFields:&error];
    
    // TODO: Display the errors to the user
}

#pragma mark UITextFieldDelegate protocol implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark HLSTextFieldValidationDelegate protocol implementation

- (void)textField:(UITextField *)textField didFailValidationWithError:(NSError *)error
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                         message:[error localizedDescription] 
                                                        delegate:nil 
                                               cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Dismiss")
                                               otherButtonTitles:nil]
                              autorelease];
    [alertView show];
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
}

@end
