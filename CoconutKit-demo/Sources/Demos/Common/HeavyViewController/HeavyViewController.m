//
//  HeavyViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/15/11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HeavyViewController.h"

@implementation HeavyViewController {
@private
    void *_largeBlock;
}

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    free(_largeBlock);
    _largeBlock = NULL;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Simulate heavy view loading by waiting two seconds
    [NSThread sleepForTimeInterval:2.];
    
    self.view.backgroundColor = [UIColor randomColor];
    
    // Simulate a heavy memory consumption for the view
    if (! _largeBlock) {
        _largeBlock = malloc(5000000);
    }
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"HeavyViewController";
}

@end
