//
//  BindingsFailuresDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 14.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "BindingsFailuresDemoViewController.h"

@interface BindingsFailuresDemoViewController ()

@property (nonatomic, strong) NSNumber *number;

@end

@implementation BindingsFailuresDemoViewController

#pragma mark Accessors and mutators

- (NSString *)readonlyString
{
    return @"Readonly keyPath";
}

- (NSDate *)date
{
    return [NSDate date];
}

#pragma mark Transformers

- (HLSBlockTransformer *)truthTransformer
{
    return [HLSBlockTransformer blockTransformerWithBlock:^(id object) {
        return @42;
    } reverseBlock:nil];
}

- (NSString *)invalidTransformer
{
    return @"invalid";
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Failures", nil);
}

#pragma mark HLSViewBindingDelegate protocol

- (void)boundView:(UIView *)boundView updateDidFailWithObject:(id)object error:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
