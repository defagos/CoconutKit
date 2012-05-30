//
//  SkinningDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 11.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "SkinningDemoViewController.h"

@implementation SkinningDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super initWithNibName:[self className] bundle:nil])) {
        
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:animated];
    
    // Set a custom image as navigation bar and toolbar backgrounds
    UIImage *barBackgroundImage = [UIImage imageNamed:@"bkgr_bar.png"];
    self.navigationController.navigationBar.backgroundImage = barBackgroundImage;
    self.navigationController.toolbar.backgroundImage = barBackgroundImage;
    
    // Make buttons appear in a similar color as the bar they are on
    UIColor *redColor = [UIColor colorWithRed:227.f / 255.f green:15.f / 255.f blue:15.f / 255.f alpha:1.f];
    self.navigationController.navigationBar.tintColor = redColor;
    self.navigationController.toolbar.tintColor = redColor;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:animated];
    
    // Reset the navigation bar and the toolbar appearance
    self.navigationController.navigationBar.backgroundImage = nil;
    self.navigationController.toolbar.backgroundImage = nil;
    
    // Reset tint colors
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.toolbar.tintColor = nil;
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return YES;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    // Installs a test button to see the benefits of a toolbar tint color
    UIBarButtonItem *actionBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:nil 
                                                                                          action:NULL] autorelease];
    self.toolbarItems = [NSArray arrayWithObject:actionBarButtonItem];
    
    self.title = NSLocalizedString(@"Skinning", @"Skinning");
}

@end
