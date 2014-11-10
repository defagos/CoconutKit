//
//  WizardIdentityPageViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/28/11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "WizardIdentityPageViewController.h"

#import "PersonInformation.h"

@interface WizardIdentityPageViewController ()

@property (nonatomic, strong) PersonInformation *personInformation;

@property (nonatomic, weak) IBOutlet UILabel *birthdateLabel;

@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *textFields;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *errorLabels;

@property (nonatomic, strong) NSDateFormatter *localizedDateFormatter;

@end

@implementation WizardIdentityPageViewController {
@private
    BOOL _loadedOnce;
}

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        // Only one person in the DB. If does not exist yet, create it
        PersonInformation *personInformation = [[PersonInformation allObjects] firstObject];
        if (! personInformation) {
            personInformation = [PersonInformation insert];
        }
        self.personInformation = personInformation;
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Bindings are resolved at the last possible moment, when the view hierarchy is built. If we want to force an initial check,
    // we need to do it afterwards
    if (! _loadedOnce) {
        [self checkDisplayedValuesWithError:NULL];
        _loadedOnce = YES;
    }
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.birthdateLabel.text = [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"Birthdate", nil), NSLocalizedString(@"yyyy/MM/dd", nil)];
    
    NSDateFormatter *localizedDateFormatter = [[NSDateFormatter alloc] init];
    [localizedDateFormatter setDateFormat:NSLocalizedString(@"yyyy/MM/dd", nil)];
    
    // Changing the date formatter object automatically triggers a bound view update
    self.localizedDateFormatter = localizedDateFormatter;
    
    // Trigger a new validation to get localized error messages if any
    [self checkDisplayedValuesWithError:NULL];
}

#pragma mark HLSValidable protocol implementation

- (BOOL)validate
{
    return [self checkDisplayedValuesWithError:NULL];
}

#pragma mark HLSBindingDelegate protocol implementation

- (void)view:(UIView *)view transformationDidFailForObject:(id)object keyPath:(NSString *)keyPath withError:(NSError *)error
{
    view.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5f];
    
    UILabel *errorLabel = [self errorLabelForView:view];
    errorLabel.text = [error localizedDescription];
}

- (void)view:(UIView *)view checkDidSucceedForObject:(id)object keyPath:(NSString *)keyPath
{
    view.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5f];
    
    UILabel *errorLabel = [self errorLabelForView:view];
    errorLabel.text = nil;
}

- (void)view:(UIView *)view checkDidFailForObject:(id)object keyPath:(NSString *)keyPath withError:(NSError *)error
{
    view.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5f];
    
    UILabel *errorLabel = [self errorLabelForView:view];
    errorLabel.text = [error localizedDescription];
}

#pragma mark Retrieving the error label associated with a view

- (UILabel *)errorLabelForView:(UIView *)view
{
    NSUInteger index = [self.textFields indexOfObject:view];
    if (index == NSNotFound) {
        return nil;
    }
    
    NSAssert([self.textFields count] == [self.errorLabels count], @"Expect one label per text field");
    return [self.errorLabels objectAtIndex:index];
}

#pragma mark Event callbacks

- (IBAction)resetModel:(id)sender
{
    // Reset the model programmatically. This shows that the text fields are updated accordingly
    self.personInformation.firstName = nil;
    self.personInformation.lastName = nil;
    self.personInformation.email = nil;
    self.personInformation.birthdate = nil;
    self.personInformation.nbrChildrenValue = 0;
}

- (IBAction)resetTextFields:(id)sender
{
    // Reset text fields programmatically. This shows that the model is updated accordingly
    for (UITextField *textField in self.textFields) {
        textField.text = nil;
    }
}

@end
