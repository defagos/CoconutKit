//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "FontsDemoViewController.h"

@interface FontsDemoViewController ()

@property (nonatomic, weak) IBOutlet UILabel *label;

@end

@implementation FontsDemoViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.label.font = [UIFont fontWithName:@"Beon-Regular" size:20.f];
}

#pragma mark Orientation management

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Font", nil);
}

@end
