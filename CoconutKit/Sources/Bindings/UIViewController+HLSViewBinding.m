//
//  UIViewController+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "UIViewController+HLSViewBinding.h"

#import "UIView+HLSExtensions.h"
#import "UIView+HLSViewBinding.h"

#import <objc/runtime.h>

// Keys for associated objects
static void *s_boundObjectKey = &s_boundObjectKey;

@interface UIViewController (HLSViewBindingPrivate)

@property (nonatomic, strong) id boundObject;

@end

@implementation UIViewController (HLSViewBinding)

#pragma mark Bindings

- (void)bindToObject:(id)object
{
    self.boundObject = object;
    
    if ([self isViewLoaded]) {
        [self.view bindToObject:object];
    }
}

- (void)refreshBindings
{
    if ([self isViewLoaded]) {
        [self.view refreshBindings];
    }
}

@end

@implementation UIViewController (HLSViewBindingPrivate)

#pragma mark Accessors and mutators

- (id)boundObject
{
    return objc_getAssociatedObject(self, s_boundObjectKey);
}

- (void)setBoundObject:(id)boundObject
{
    objc_setAssociatedObject(self, s_boundObjectKey, boundObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
