//
//  UIViewController+HLSViewBinding.m
//  mBanking
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "UIViewController+HLSViewBinding.h"

#import "HLSRuntime.h"
#import "UIView+HLSExtensions.h"
#import "UIView+HLSViewBinding.h"
#import "UIView+HLSViewBindingFriend.h"

// Keys for associated objects
static void *s_boundObjectKey = &s_boundObjectKey;

// Original implementation of the methods we swizzle
static void (*s_UIViewController__viewDidLoad_Imp)(id, SEL) = NULL;

// Swizzled method implementations
static void swizzled_UIViewController__viewDidLoad_Imp(UIViewController *self, SEL _cmd);

@interface UIViewController (HLSViewBindingPrivate)

@property (nonatomic, strong) id boundObject;

@end

@implementation UIViewController (HLSViewBinding)

#pragma mark Class methods

+ (void)load
{
    s_UIViewController__viewDidLoad_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self,
                                                                                @selector(viewDidLoad),
                                                                                (IMP)swizzled_UIViewController__viewDidLoad_Imp);
}

#pragma mark Bindings

- (void)bindToObject:(id)object
{
    self.boundObject = object;
    
    // If the view has not deserialized when the object is bound, will do it in -awakeFromNib via swizzling
    if ([self isViewLoaded]) {
        [self.view bindToObject:object inViewController:self];
    }
}

- (void)refreshBindings
{
    [self.view refreshBindingsInViewController:self];
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

#pragma mark Swizzled method implementations

static void swizzled_UIViewController__viewDidLoad_Imp(UIViewController *self, SEL _cmd)
{
    (*s_UIViewController__viewDidLoad_Imp)(self, _cmd);
    
    if (self.boundObject) {
        [self.view bindToObject:self.boundObject inViewController:self];
    }
}
