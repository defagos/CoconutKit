//
//  StackDemoViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "StackDemoViewController.h"

#import "LifeCycleTestViewController.h"

@interface StackDemoViewController ()

- (void)lifeCycleTestSampleButtonClicked:(id)sender;
- (void)popButtonClicked:(id)sender;

@end

@implementation StackDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.title = @"HLSStackController";
        
        UIViewController *rootViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        self.insetViewController = [[[HLSStackController alloc] initWithRootViewController:rootViewController] autorelease];
        self.adjustingInset = YES;
    }
    return self;
}

- (void)releaseViews
{ 
    [super releaseViews];
    
    self.lifecycleTestSampleButton = nil;
    self.popButton = nil;
}

#pragma mark Accessors and mutators

@synthesize lifecycleTestSampleButton = m_lifecycleTestSampleButton;

@synthesize popButton = m_popButton;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.lifecycleTestSampleButton setTitle:NSLocalizedString(@"Lifecycle test", @"Lifecycle test")
                                    forState:UIControlStateNormal];
    [self.lifecycleTestSampleButton addTarget:self
                                       action:@selector(lifeCycleTestSampleButtonClicked:)
                             forControlEvents:UIControlEventTouchUpInside];
    
    [self.popButton setTitle:NSLocalizedString(@"Pop", @"Pop")
                    forState:UIControlStateNormal];
    [self.popButton addTarget:self
                       action:@selector(popButtonClicked:)
             forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark Event callbacks

- (void)lifeCycleTestSampleButtonClicked:(id)sender
{
    HLSStackController *stackController = (HLSStackController *)self.insetViewController;
    LifeCycleTestViewController *lifeCycleTestViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
    [stackController pushViewController:lifeCycleTestViewController];
}

- (void)popButtonClicked:(id)sender
{
    HLSStackController *stackController = (HLSStackController *)self.insetViewController;
    [stackController popViewController];
}

@end
