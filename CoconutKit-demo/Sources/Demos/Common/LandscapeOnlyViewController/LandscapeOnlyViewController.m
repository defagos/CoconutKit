//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "LandscapeOnlyViewController.h"

@implementation LandscapeOnlyViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
}

#pragma mark Orientation management

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskLandscape;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"LandscapeOnlyViewController";
}

@end
