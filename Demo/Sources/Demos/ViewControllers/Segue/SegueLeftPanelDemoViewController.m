//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SegueLeftPanelDemoViewController.h"

@implementation SegueLeftPanelDemoViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
}

#pragma mark Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue isKindOfClass:[HLSPlaceholderInsetSegue class]]) {
        HLSPlaceholderInsetSegue *placeholderInsetSegue = (HLSPlaceholderInsetSegue *)segue;
        placeholderInsetSegue.index = 1;
        if ([placeholderInsetSegue.identifier isEqualToString:@"firstPanel"]) {
            placeholderInsetSegue.transitionClass = [HLSTransitionCrossDissolve class];
        }
        else if ([placeholderInsetSegue.identifier isEqualToString:@"secondPanel"]) {
            placeholderInsetSegue.transitionClass = [HLSTransitionCoverFromRight class];
        }
    }
}

@end
