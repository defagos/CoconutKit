//
//  MemoryWarningTestCoverViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/15/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "MemoryWarningTestCoverViewController.h"

@interface MemoryWarningTestCoverViewController ()

- (void)closeBarButtonItemClicked:(id)sender;

@end

@implementation MemoryWarningTestCoverViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.title = @"MemoryWarningTestCoverViewController";
    }
    return self;
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.closeBarButtonItem = nil;
    self.instructionLabel = nil;
}

#pragma mark Accessors and mutators

@synthesize closeBarButtonItem = m_closeBarButtonItem;

@synthesize instructionLabel = m_instructionLabel;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.closeBarButtonItem.title = NSLocalizedString(@"Close", @"Close");
    self.closeBarButtonItem.target = self;
    self.closeBarButtonItem.action = @selector(closeBarButtonItemClicked:);
    
    self.instructionLabel.text = NSLocalizedString(@"In the simulator, trigger a memory warning and dismiss this view to check that the behavior is correct",
                                                   @"In the simulator, trigger a memory warning and dismiss this view to check that the behavior is correct");
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

- (void)closeBarButtonItemClicked:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
