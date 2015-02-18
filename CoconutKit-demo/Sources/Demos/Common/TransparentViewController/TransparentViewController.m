//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "TransparentViewController.h"

@implementation TransparentViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.view.backgroundColor = [UIColor randomColor];
    self.view.alpha = 0.5f;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"TransparentViewController";
}

@end
