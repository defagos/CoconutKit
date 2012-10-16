//
//  HeavyViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/15/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HeavyViewController.h"

@implementation HeavyViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    free(m_largeBlock);
    m_largeBlock = NULL;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Simulate heavy view loading by waiting two seconds
    [NSThread sleepForTimeInterval:2.];
    
    self.view.backgroundColor = [UIColor randomColor];
    
    // Simulate a heavy memory consumption for the view
    if (! m_largeBlock) {
        m_largeBlock = malloc(5000000);
    }
}

#pragma mark Orientation management

- (BOOL)shouldAutorotate
{
    if (! [super shouldAutorotate]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & HLSInterfaceOrientationMaskAll;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"HeavyViewController";
}

@end
