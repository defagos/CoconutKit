//
//  OrientationClonerViewController.m
//  nut-demo
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

- (id)initWithPortraitOrientation:(BOOL)portraitOrientation
{
    if (portraitOrientation) {
        self = [super initWithNibName:@"OrientationClonerViewControllerPortrait" bundle:nil];
        self.title = @"OrientationClonerViewController (Portrait)";
    }
    else {
        self = [super initWithNibName:@"OrientationClonerViewControllerLandscape" bundle:nil];
        self.title = @"OrientationClonerViewController (Landscape)";
    }
    return self;
}

- (id)init
{
    return [self initWithPortraitOrientation:YES];
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
    OrientationClonerViewController *viewControllerClone = [[[OrientationClonerViewController alloc] initWithPortraitOrientation:UIInterfaceOrientationIsPortrait(orientation)] 
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

@end
