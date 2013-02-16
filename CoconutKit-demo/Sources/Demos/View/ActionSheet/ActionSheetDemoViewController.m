//
//  ActionSheetDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 25.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "ActionSheetDemoViewController.h"

@interface ActionSheetDemoViewController ()

- (HLSActionSheet *)actionSheetForChoice;
- (void)showSecondActionSheetFromActionSheet:(HLSActionSheet *)actionSheet;

- (void)choose1:(id)sender;
- (void)choose2:(id)sender;
- (void)choose3:(id)sender;
- (void)choose4:(id)sender;
- (void)cancel;

@end

@implementation ActionSheetDemoViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.toolbar = nil;
    self.choiceLabel = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.choiceLabel.text = @"0";
}

#pragma mark Orientation management

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.tabBarController.title = NSLocalizedString(@"Action sheet", @"Action sheet");
}

#pragma mark Common action sheet code

- (HLSActionSheet *)actionSheetForChoice
{
    HLSActionSheet *actionSheet = [[[HLSActionSheet alloc] init] autorelease];
    [actionSheet addDestructiveButtonWithTitle:NSLocalizedString(@"Reset", @"Reset") 
                                        target:self
                                        action:@selector(resetChoice:)];
    [actionSheet addButtonWithTitle:@"1"
                             target:self
                             action:@selector(choose1:)];
    [actionSheet addButtonWithTitle:@"2"
                             target:self
                             action:@selector(choose2:)];
    [actionSheet addButtonWithTitle:@"3"
                             target:self
                             action:@selector(choose3:)];
    [actionSheet addButtonWithTitle:@"4"
                             target:self
                             action:@selector(choose4:)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [actionSheet addCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel") target:self action:@selector(cancel)];
    }
    
    return actionSheet;
}

- (void)showSecondActionSheetFromActionSheet:(HLSActionSheet *)actionSheet
{
    HLSActionSheet *secondActionSheet = [[[HLSActionSheet alloc] init] autorelease];
    [secondActionSheet addButtonWithTitle:HLSLocalizedStringFromUIKit(@"Yes") target:nil action:NULL];
    [secondActionSheet addButtonWithTitle:[HLSLocalizedStringFromUIKit(@"No") capitalizedString] target:nil action:NULL];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [secondActionSheet addCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel") target:self action:@selector(cancel)];
    }
    
    if ([actionSheet.owner isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *ownerBarButtonItem = (UIBarButtonItem *)actionSheet.owner;
        [secondActionSheet showFromBarButtonItem:ownerBarButtonItem animated:YES];
    }
    else if ([actionSheet.owner isKindOfClass:[UIToolbar class]]) {
        UIToolbar *ownerToolbar = (UIToolbar *)actionSheet.owner;
        [secondActionSheet showFromToolbar:ownerToolbar];
    }
    else if ([actionSheet.owner isKindOfClass:[UITabBar class]]) {
        UITabBar *ownerTabBar = (UITabBar *)actionSheet.owner;
        [secondActionSheet showFromTabBar:ownerTabBar];
    }
    else if ([actionSheet.owner isKindOfClass:[UIView class]]) {
        UIView *ownerView = (UIView *)actionSheet.owner;
        [secondActionSheet showInView:ownerView];
    }
}

#pragma mark Event callbacks

- (IBAction)makeChoiceFromRectAnimated:(id)sender
{
    UIButton *button = sender;
    HLSActionSheet *actionSheet = [self actionSheetForChoice];
    [actionSheet showFromRect:button.frame inView:self.view animated:YES];
}

- (IBAction)makeChoiceFromRectNotAnimated:(id)sender
{
    UIButton *button = sender;
    HLSActionSheet *actionSheet = [self actionSheetForChoice];
    [actionSheet showFromRect:button.frame inView:self.view animated:NO];
}

// Test method without parameter (checks UIBarButtonItem+HLSActionSheet implementation correctness. Bar
// button actions can namely have a sender parameter, but this is not required)
- (IBAction)makeChoiceInView
{
    HLSActionSheet *actionSheet = [self actionSheetForChoice];
    [actionSheet showInView:self.view];
}

- (IBAction)makeChoiceFromToolbar:(id)sender
{
    HLSActionSheet *actionSheet = [self actionSheetForChoice];
    [actionSheet showFromToolbar:self.toolbar];
}

- (IBAction)makeChoiceFromTabBar:(id)sender
{
    HLSActionSheet *actionSheet = [self actionSheetForChoice];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (IBAction)makeChoiceFromBarButtonItemAnimated:(id)sender
{
    UIBarButtonItem *barButtonItem = sender;
    HLSActionSheet *actionSheet = [self actionSheetForChoice];
    [actionSheet showFromBarButtonItem:barButtonItem animated:YES];
}

- (IBAction)makeChoiceFromBarButtonItemNotAnimated:(id)sender
{
    UIBarButtonItem *barButtonItem = sender;
    HLSActionSheet *actionSheet = [self actionSheetForChoice];
    [actionSheet showFromBarButtonItem:barButtonItem animated:NO];
}

- (void)choose1:(id)sender
{
    self.choiceLabel.text = @"1";
    [self showSecondActionSheetFromActionSheet:sender];
}

- (void)choose2:(id)sender
{
    self.choiceLabel.text = @"2";
    [self showSecondActionSheetFromActionSheet:sender];
}

- (void)choose3:(id)sender
{
    self.choiceLabel.text = @"3";
    [self showSecondActionSheetFromActionSheet:sender];
}

- (void)choose4:(id)sender
{
    self.choiceLabel.text = @"4";
    [self showSecondActionSheetFromActionSheet:sender];
}

// Has no sender parameter. Works too!
- (void)cancel
{
    self.choiceLabel.text = nil;
}

- (IBAction)resetChoice:(id)sender
{
    self.choiceLabel.text = @"0";
}

@end
