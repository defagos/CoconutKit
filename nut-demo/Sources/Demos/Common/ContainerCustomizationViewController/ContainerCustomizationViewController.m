//
//  ContainerCustomizationViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "ContainerCustomizationViewController.h"

@interface ContainerCustomizationViewController ()

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
}

#pragma mark Accessors and mutators

@synthesize changeButton = m_changeButton;

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

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return YES;
}

#pragma mark Event callbacks

- (void)changeButtonClicked:(id)sender
{   
    self.navigationController.navigationBar.tintColor = [UIColor randomColor];
    
    // Puts a random button on the right
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:arc4random() % 10
                                                                                            target:nil 
                                                                                            action:NULL]
                                              autorelease];
}

@end
