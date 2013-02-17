//
//  FixedSizeViewController
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/15/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "FixedSizeViewController.h"

@implementation FixedSizeViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"FixedSizeViewController";
}

@end
