//
//  HLSContainerGroupView.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/5/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSContainerGroupView.h"

#import "HLSAssert.h"
#import "HLSContainerStackView.h"
#import "HLSLogger.h"
#import "NSArray+HLSExtensions.h"
#import "UIView+HLSExtensions.h"

@implementation HLSContainerGroupView

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame frontView:(UIView *)frontView
{
    if ((self = [super initWithFrame:frame])) {
        if (! frontView) {
            HLSLoggerError(@"A front view is mandatory");
            [self release];
            return nil;
        }
        
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = HLSViewAutoresizingAll;
        
        // Remark: If the view was previously added to another superview, it is removed
        //         while kept alive. No need to call -removeFromSuperview and no need
        //         for a retain-autorelease. See UIView documentation
        [self addSubview:frontView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    HLSForbiddenInheritedMethod();
    return nil;
}

#pragma mark Accessors and mutators

- (UIView *)frontView
{
    return [self.subviews lastObject];
}

- (HLSContainerGroupView *)backGroupView
{
    if ([self.subviews count] == 2) {
        return [self.subviews firstObject];
    }
    else {
        return nil;
    }
}

- (void)setBackGroupView:(HLSContainerGroupView *)backGroupView
{
    if ([self.subviews count] == 2) {
        [[self.subviews objectAtIndex:0] removeFromSuperview];
    }
    
    if (backGroupView) {
        // Remark: If the view was previously added to another superview, it is removed
        //         while kept alive. No need to call -removeFromSuperview and no need
        //         for a retain-autorelease. See UIView documentation
        [self insertSubview:backGroupView atIndex:0];
    }
}

@end
