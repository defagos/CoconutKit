//
//  ContainerCustomizationViewController.m
//  nut-demo
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

- (void)changeButtonClicked:(id)sender;

@end

@implementation ContainerCustomizationViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.title = @"ContainerCustomizationViewController";
    }
    return self;
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.changeButton = nil;
    self.originalNavigationBarTintColor = nil;
    self.originalRightBarButtonItem = nil;
}

#pragma mark Accessors and mutators

@synthesize changeButton = m_changeButton;

@synthesize originalNavigationBarTintColor = m_originalNavigationBarTintColor;

@synthesize originalRightBarButtonItem = m_originalRightBarButtonItem;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.changeButton setTitle:NSLocalizedString(@"Change", @"Change")
                       forState:UIControlStateNormal];
    [self.changeButton addTarget:self
                          action:@selector(changeButtonClicked:)
                forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self saveOriginalSkin];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
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
}

- (void)restoreOriginalSkin
{
    self.navigationController.navigationBar.tintColor = self.originalNavigationBarTintColor;
    self.navigationItem.rightBarButtonItem = self.originalRightBarButtonItem;
}

#pragma mark Event callbacks

- (void)changeButtonClicked:(id)sender
{
    [self updateSkinRandomly];
}

@end
