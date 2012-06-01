//
//  ContainerCustomizationViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "ContainerCustomizationViewController.h"

@interface ContainerCustomizationViewController ()

@property (nonatomic, retain) UIColor *originalNavigationBarTintColor;
@property (nonatomic, retain) UIBarButtonItem *originalRightBarButtonItem;

- (void)saveOriginalSkin;
- (void)updateSkinRandomly;
- (void)restoreOriginalSkin;

@end

@implementation ContainerCustomizationViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.originalNavigationBarTintColor = nil;
    self.originalRightBarButtonItem = nil;
}

#pragma mark Accessors and mutators

@synthesize originalNavigationBarTintColor = m_originalNavigationBarTintColor;

@synthesize originalRightBarButtonItem = m_originalRightBarButtonItem;

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:animated];
    
    [self saveOriginalSkin];
    [self updateSkinRandomly];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:animated];
    
    [self restoreOriginalSkin];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return YES;
}

#pragma mark Changing appearance

- (void)saveOriginalSkin
{
    self.originalNavigationBarTintColor = self.navigationController.navigationBar.tintColor;
    self.originalRightBarButtonItem = self.navigationItem.rightBarButtonItem;
}

- (void)updateSkinRandomly
{
    self.navigationController.navigationBar.tintColor = [UIColor randomColor];
    
    // Puts a random button on the right
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:arc4random() % 4
                                                                                            target:nil 
                                                                                            action:NULL]
                                              autorelease];
    
    UIBarButtonItem *toolbarItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:arc4random() % 4
                                                                                  target:nil 
                                                                                  action:NULL]
                                    autorelease];
    self.toolbarItems = [NSArray arrayWithObject:toolbarItem];
}

- (void)restoreOriginalSkin
{
    self.navigationController.navigationBar.tintColor = self.originalNavigationBarTintColor;
    self.navigationItem.rightBarButtonItem = self.originalRightBarButtonItem;
}

#pragma mark Event callbacks

- (IBAction)changeAppearance:(id)sender
{
    [self updateSkinRandomly];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"ContainerCustomizationViewController";
}

@end
