//
//  PortraitOnlyViewController
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/15/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "PortraitOnlyViewController.h"

@implementation PortraitOnlyViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    HLSLoggerInfo(@"Called for object %@, displayedInterfaceOrientation = %@", self, HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
}

#pragma mark Orientation management

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    HLSLoggerInfo(@"Called for object %@, displayedInterfaceOrientation = %@", self, HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"PortraitOnlyViewController";
}

@end
