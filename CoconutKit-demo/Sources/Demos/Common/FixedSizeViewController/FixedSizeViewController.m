//
//  FixedSizeViewController
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/15/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "FixedSizeViewController.h"

@implementation FixedSizeViewController

#pragma mark Object creation and destruction

- (id)initLarge:(BOOL)large
{
    if (large) {
        if ((self = [super initWithNibName:@"FixedSizeLargeViewController" bundle:nil])) {
            self.title = @"FixedSizeViewController (large)";
        }
    }
    else {
        if ((self = [super initWithNibName:@"FixedSizeViewController" bundle:nil])) {
            self.title = @"FixedSizeViewController";
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
