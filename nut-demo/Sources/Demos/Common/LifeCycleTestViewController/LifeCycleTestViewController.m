//
//  LifeCycleTestViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 2/15/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "LifeCycleTestViewController.h"

@implementation LifeCycleTestViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.title = @"LifeCycleTestViewController";
    }
    return self;
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.instructionLabel = nil;
}

#pragma mark Accessors and mutators

@synthesize instructionLabel = m_instructionLabel;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.instructionLabel.text = NSLocalizedString(@"Check your log window to see view lifecycle and rotation events (logging level must be at least INFO)",
                                                   @"Check your log window to see view lifecycle and rotation events (logging level must be at least INFO)");
    
    self.view.backgroundColor = [UIColor colorWithRed:(rand() % 256)/256.f
                                                green:(rand() % 256)/256.f 
                                                 blue:(rand() % 256)/256.f 
                                                alpha:1.f];    
    
    HLSLoggerInfo(@"Called for object %@", self);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@", self, [HLSConverters stringFromBool:animated]);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@", self, [HLSConverters stringFromBool:animated]);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@", self, [HLSConverters stringFromBool:animated]);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@", self, [HLSConverters stringFromBool:animated]);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    HLSLoggerInfo(@"Called for object %@", self);
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    HLSLoggerInfo(@"Called, toInterfaceOrientation = %@", [HLSConverters stringFromInterfaceOrientation:toInterfaceOrientation]);
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{   
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    HLSLoggerInfo(@"Called, toInterfaceOrientation = %@", [HLSConverters stringFromInterfaceOrientation:toInterfaceOrientation]);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    HLSLoggerInfo(@"Called, toInterfaceOrientation = %@", [HLSConverters stringFromInterfaceOrientation:toInterfaceOrientation]);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    HLSLoggerInfo(@"Called, fromInterfaceOrientation = %@", [HLSConverters stringFromInterfaceOrientation:fromInterfaceOrientation]);
}

@end
