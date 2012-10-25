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
static void *s_compatibleWithNewRotationMethodsKey = &s_compatibleWithNewRotationMethodsKey;

@implementation UIViewController (HLSAutorotationPreSDK6Compatibility)

- (BOOL)isCompatibleWithNewRotationMethods
{
    NSNumber *compatibleWithNewRotationMethodsNumber = objc_getAssociatedObject(self, s_compatibleWithNewRotationMethodsKey);
    if (! compatibleWithNewRotationMethodsNumber) {
        return YES;
    }
    else {
        return [compatibleWithNewRotationMethodsNumber boolValue];
    }
}

- (void)setCompatibleWithNewRotationMethods:(BOOL)compatibleWithNewRotationMethods
{
    objc_setAssociatedObject(self, s_compatibleWithNewRotationMethodsKey, [NSNumber numberWithBool:compatibleWithNewRotationMethods],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
