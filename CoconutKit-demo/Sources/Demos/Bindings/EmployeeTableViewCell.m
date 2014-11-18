//
//  EmployeeTableViewCell.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 26.07.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "EmployeeTableViewCell.h"

@implementation EmployeeTableViewCell

#pragma mark Transformers

+ (HLSBlockTransformer *)numberToAgeStringTransformer
{
    static dispatch_once_t s_onceToken;
    static HLSBlockTransformer *s_transformer;
    dispatch_once(&s_onceToken, ^{
        s_transformer = [HLSBlockTransformer blockTransformerWithBlock:^(NSNumber *number) {
            return [NSString stringWithFormat:NSLocalizedString(@"Age: %@", nil), number];
        } reverseBlock:nil];
    });
    return s_transformer;
}

@end
