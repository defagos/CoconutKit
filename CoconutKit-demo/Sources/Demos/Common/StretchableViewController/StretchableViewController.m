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
    if (large) {
        if ((self = [super initWithNibName:@"StretchableLargeViewController" bundle:nil])) {
            self.title = @"StretchableViewController (large)";
        }                
    }
    else {
        if ((self = [super initWithNibName:@"StretchableViewController" bundle:nil])) {
            self.title = @"StretchableViewController";
        }        
    }
    return self;
}

- (id)init
{
    return [self initLarge:NO];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return YES;
}

@end
