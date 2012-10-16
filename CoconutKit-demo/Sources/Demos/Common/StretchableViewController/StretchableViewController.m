//
//  StretchableViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/14/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "StretchableViewController.h"

@implementation StretchableViewController

#pragma mark Object creation and destruction

- (id)initLarge:(BOOL)large
{
    if ((self = [super initWithNibName:large ? @"StretchableLargeViewController" : @"StretchableViewController" bundle:nil])) {
        self.large = large;
    }
    return self;
}

- (id)init
{
    return [self initLarge:NO];
}

#pragma mark Accessors and mutators

@synthesize large = m_large;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
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
    
    self.title = self.isLarge ? @"StretchableViewController (large)" : @"StretchableViewController";
}

@end
