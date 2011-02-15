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
    if (self = [super init]) {
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
    
    logger_info(@"Called for object %@", self);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    logger_info(@"Called for object %@, animated = %@", self, [HLSConverters stringFromBool:animated]);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    logger_info(@"Called for object %@, animated = %@", self, [HLSConverters stringFromBool:animated]);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    logger_info(@"Called for object %@, animated = %@", self, [HLSConverters stringFromBool:animated]);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    logger_info(@"Called for object %@, animated = %@", self, [HLSConverters stringFromBool:animated]);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    logger_info(@"Called for object %@", self);
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    logger_info(@"Called!");
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{   
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    logger_info(@"Called!");
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    logger_info(@"Called!");
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    logger_info(@"Called!");
}

@end
