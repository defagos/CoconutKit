//
//  MemoryWarningTestCoverViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/15/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "MemoryWarningTestCoverViewController.h"

@interface MemoryWarningTestCoverViewController ()

@property (nonatomic, retain) IBOutlet UIBarButtonItem *closeBarButtonItem;

@end

@implementation MemoryWarningTestCoverViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.closeBarButtonItem = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.closeBarButtonItem.target = self;
    self.closeBarButtonItem.action = @selector(close:);
}

#pragma mark Event callbacks

- (void)close:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"MemoryWarningTestCoverViewController";
    self.closeBarButtonItem.title = NSLocalizedString(@"Close", nil);
}

@end
