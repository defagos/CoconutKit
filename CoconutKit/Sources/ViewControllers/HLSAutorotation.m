//
//  HLSAutorotation.m
//  CoconutKit
//
//  Created by Samuel Défago on 10/16/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSAutorotation.h"

#import "HLSRuntime.h"

// Associated object keys
static void *s_compatibleWithNewAutorotationMethodsKey = &s_compatibleWithNewAutorotationMethodsKey;

@implementation UIViewController (HLSAutorotationPreSDK6Compatibility)

- (BOOL)isCompatibleWithNewAutorotationMethods
{
    NSNumber *compatibleWithNewAutorotationMethodsNumber = objc_getAssociatedObject(self, s_compatibleWithNewAutorotationMethodsKey);
    if (! compatibleWithNewAutorotationMethodsNumber) {
        return YES;
    }
    else {
        return [compatibleWithNewAutorotationMethodsNumber boolValue];
    }
}

- (void)setCompatibleWithNewAutorotationMethods:(BOOL)compatibleWithNewAutorotationMethods
{
    objc_setAssociatedObject(self, s_compatibleWithNewAutorotationMethodsKey, [NSNumber numberWithBool:compatibleWithNewAutorotationMethods],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
