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

#pragma mark Overrides

+ (NSBundle *)bundle
{
    return [NSBundle coconutKitBundle];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.valueLabel.verticalAlignment = HLSLabelVerticalAlignmentTop;
}

@end
