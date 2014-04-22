//
//  HLSInfoTableViewCell.m
//  CoconutKit
//
//  Created by Samuel Défago on 04/12/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSInfoTableViewCell.h"

#import "NSBundle+HLSExtensions.h"

@implementation HLSInfoTableViewCell

#pragma mark Class methods

+ (CGFloat)heightForValue:(NSString *)value
{
    static CGFloat s_baseHeight;
    static CGSize s_constraintSize;
    
    static dispatch_once_t s_onceToken;
    static HLSInfoTableViewCell *s_cell;
    dispatch_once(&s_onceToken, ^{
        s_cell = [HLSInfoTableViewCell cellForTableView:nil];
        s_baseHeight = CGRectGetHeight(s_cell.frame) - CGRectGetHeight(s_cell.valueLabel.frame);
        s_constraintSize = CGSizeMake(CGRectGetWidth(s_cell.valueLabel.frame), CGFLOAT_MAX);
    });
    
    return s_baseHeight + [value sizeWithFont:s_cell.valueLabel.font constrainedToSize:s_constraintSize].height + 20.f;
}

#pragma mark Overrides

+ (NSBundle *)bundle
{
    return [NSBundle coconutKitBundle];
}

@end
