//
//  OrientationClonerViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/16/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "OrientationClonerViewController.h"

@interface OrientationClonerViewController ()

// Text field content must be backed up by a variable. Usually this is some model object managed by the controller,
// but here we keep everything simple. This is needed otherwise:
//   - the text field value would be lost if the text field is released (e.g. because of a memory warning)
//   - the text field value cannot be cloned, since the clone text field does not exist at creation time (it is only
//     when the view is instantiated that it is available, and we do not want to force view creation just to set
//     an outlet!)
@property (nonatomic, retain) NSString *text;

@end

@implementation OrientationClonerViewController

#pragma mark Object creation and destruction

- (id)initWithPortraitOrientation:(BOOL)portraitOrientation large:(BOOL)large
{
    NSString *nibName = nil;
    if (portraitOrientation) {
        if (large) {
            nibName = @"OrientationClonerLargeViewControllerPortrait";
        }
        else {
            nibName = @"OrientationClonerViewControllerPortrait";
        }
    }
    else {
        if (large) {
            nibName = @"OrientationClonerLargeViewControllerLandscape";
        }
        else {
            nibName = @"OrientationClonerViewControllerLandscape";
        }
    }
    
    if ((self = [super initWithNibName:nibName bundle:nil])) {
        self.large = large;
    }
    return self;
}

- (id)init
{
    return [self initWithPortraitOrientation:YES large:NO];
}

- (void)dealloc
{
    self.text = nil;
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.textField = nil;
}

#pragma mark Accessors and mutators

@synthesize textField = m_textField;

@synthesize portraitOrientation = m_portraitOrientation;

@synthesize large = m_large;

@synthesize text = m_text;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textField.delegate = self;
    
    [self reloadData];
}

#pragma mark HLSOrientationCloner protocol implementation

- (UIViewController *)viewControllerCloneWithOrientation:(UIInterfaceOrientation)orientation
{
    OrientationClonerViewController *viewControllerClone = [[[OrientationClonerViewController alloc] initWithPortraitOrientation:UIInterfaceOrientationIsPortrait(orientation)
                                                                                                                           large:m_large] 
                                                            autorelease];
    
    // Clone any meaningful internal variables here
    viewControllerClone.text = self.text;
    
    return viewControllerClone;
}

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{
    self.textField.text = self.text;
}

#pragma mark UITextFieldDelegate protocol implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    // Sync data with screen
    self.text = self.textField.text;
    
    return YES;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    if (self.isPortraitOrientation) {
        if (self.isLarge) {
            self.title = @"OrientationClonerViewController (portrait, large)";
        }
        else {
            self.title = @"OrientationClonerViewController (portrait)";
        }
    }
    else {
        if (self.isLarge) {
            self.title = @"OrientationClonerViewController (landscape, large)";
        }
        else {
            self.title = @"OrientationClonerViewController (landscape)";
        }
    }
}

@end
