//
//  ControlBindingsDemo2ViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 22/04/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "ControlBindingsDemo2ViewController.h"

@interface ControlBindingsDemo2ViewController ()

@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) NSNumber *loading;
@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) NSDateFormatter *localizedDateFormatter;

@end

@implementation ControlBindingsDemo2ViewController

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        self.page = @3;
        self.loading = @YES;
        self.date = [NSDate dateWithTimeIntervalSince1970:0.];
    }
    return self;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    NSDateFormatter *localizedDateFormatter = [[NSDateFormatter alloc] init];
    [localizedDateFormatter setDateFormat:NSLocalizedString(@"yyyy/MM/dd", nil)];
    
    // Changing the date formatter object automatically triggers a bound view update
    self.localizedDateFormatter = localizedDateFormatter;
}

@end
