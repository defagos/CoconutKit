//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "BindingsPerformance1DemoViewController.h"

@interface BindingsPerformance1DemoViewController ()

@property (nonatomic, strong) NSString *name;

@end

@implementation BindingsPerformance1DemoViewController

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        self.name = @"Tom";
    }
    return self;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Performance 1", nil);
}

@end
