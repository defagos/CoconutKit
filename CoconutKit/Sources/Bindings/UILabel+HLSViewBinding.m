//
//  UILabel+HLSViewBinding.m
//  mBanking
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "UILabel+HLSViewBinding.h"

@implementation UILabel (HLSViewBinding)

#pragma mark HLSViewBinding protocol implementation

- (void)updateViewWithText:(NSString *)text
{
    self.text = text;
}

- (BOOL)updatesSubviewsRecursively
{
    return NO;
}

@end
