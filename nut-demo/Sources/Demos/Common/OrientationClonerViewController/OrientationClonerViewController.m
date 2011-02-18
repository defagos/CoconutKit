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

- (id)initWithPortraitOrientation:(BOOL)portraitOrientation large:(BOOL)large
{
    if (portraitOrientation) {
        if (large) {
            self = [super initWithNibName:@"OrientationClonerLargeViewControllerPortrait" bundle:nil];
            if (self) {
                self.title = @"OrientationClonerViewController (portrait, large)";
                m_large = large;
            }            
        }
        else {
            self = [super initWithNibName:@"OrientationClonerViewControllerPortrait" bundle:nil];
            if (self) {
                self.title = @"OrientationClonerViewController (portrait)";
                m_large = large;
            }            
        }
    }
    else {
        if (large) {
            self = [super initWithNibName:@"OrientationClonerLargeViewControllerLandscape" bundle:nil];
            if (self) {
                self.title = @"OrientationClonerViewController (landscape, large)";
                m_large = large;
            }            
        }
        else {
            self = [super initWithNibName:@"OrientationClonerViewControllerLandscape" bundle:nil];
            if (self) {
                self.title = @"OrientationClonerViewController (landscape)";
                m_large = large;
            }            
        }
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

@end
