//
//  ControlBindingsDemo2ViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 22/04/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "ControlBindingsDemo2ViewController.h"

@interface ControlBindingsDemo2ViewController ()

@property (nonatomic, assign) NSUInteger page;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) NSDateFormatter *localizedDateFormatter;

@end

@implementation ControlBindingsDemo2ViewController

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        self.page = 3;
        self.loading = YES;
        self.date = [NSDate dateWithTimeIntervalSince1970:0.];
    }
    return self;
}

#pragma mark Accessors and mutators

- (UIImage *)apple1Image
{
    return [UIImage imageNamed:@"img_apple1.jpg"];
}

- (NSString *)apple2ImageName
{
    return @"img_apple2.jpg";
}

- (NSString *)apple3ImagePath
{
    return [[NSBundle mainBundle] pathForResource:@"img_apple3" ofType:@"jpg"];
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

#pragma mark HLSBindingDelegate protocol implementation

- (void)view:(UIView *)view checkDidSucceedForObject:(id)object keyPath:(NSString *)keyPath
{
    HLSLoggerInfo(@"Check did succeed for object %@ bound to view %@ with keypath %@", object, view, keyPath);
}

- (void)view:(UIView *)view checkDidFailForObject:(id)object keyPath:(NSString *)keyPath withError:(NSError *)error
{
    HLSLoggerInfo(@"Check did fail for object %@ bound to view %@ with keypath %@; reason %@", object, view, keyPath, error);
}

- (void)view:(UIView *)view updateDidSucceedForObject:(id)object keyPath:(NSString *)keyPath
{
    HLSLoggerInfo(@"Update did succeed for object %@ bound to view %@ with keypath %@", object, view, keyPath);
}

- (void)view:(UIView *)view updateDidFailForObject:(id)object keyPath:(NSString *)keyPath withError:(NSError *)error
{
    HLSLoggerInfo(@"Update did fail for object %@ bound to view %@ with keypath %@; reason %@", object, view, keyPath, error);
}

@end
