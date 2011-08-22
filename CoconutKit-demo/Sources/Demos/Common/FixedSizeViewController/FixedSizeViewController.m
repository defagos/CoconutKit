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
    if ((self = [super initWithNibName:large ? @"FixedSizeLargeViewController" : @"FixedSizeViewController" bundle:nil])) {
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return YES;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = self.isLarge ? @"FixedSizeViewController (large)" : @"FixedSizeViewController";
}

@end
