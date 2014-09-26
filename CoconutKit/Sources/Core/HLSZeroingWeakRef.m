//
//  HLSZeroingWeakRef.m
//  CoconutKit
//
//  Created by Samuel Défago on 28.03.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "HLSZeroingWeakRef.h"

#import <objc/runtime.h>
#import "NSObject+HLSExtensions.h"

// Associated object keys
static void *s_zeroingWeakRefListKey = &s_zeroingWeakRefListKey;

// Static methods
static void subclass_dealloc(id object, SEL _cmd);
static Class subclass_class(id object, SEL _cmd);

@interface HLSZeroingWeakRef ()

@property (nonatomic, weak) id object;
@property (nonatomic, strong) NSMutableArray *invocations;

@end

@implementation HLSZeroingWeakRef

#pragma mark Object creation and destruction

- (id)initWithObject:(id)object
{
    if ((self = [super init])) {
        self.invocations = [NSMutableArray array];
        self.object = object;
        
        if (object) {
            static NSString * const kSubclassPrefix = @"HLSZeroingWeakRef_";
            
            // Access the real class, do not use [self class] here since can be faked
            Class class = object_getClass(object);
            
            // No support for Core Foundation objects (lead to infinite recursion)
            // For more information, see
            //   http://www.mikeash.com/pyblog/friday-qa-2010-01-22-toll-free-bridging-internals.html
            if ([NSStringFromClass(class) hasPrefix:@"NSCF"] || [NSStringFromClass(class) hasPrefix: @"__NSCF"]) {
                @throw [NSException exceptionWithName:NSInvalidArgumentException 
                                               reason:@"Cannot create zeroing weak references to toll-free bridged objects"
                                             userInfo:nil];
            }
            
            // Dynamically subclass the object class to override -dealloc selectively, and use this class instead.
            // Another approach would involve swizzling -dealloc at the NSObject level, but this solution would 
            // incur an unacceptable overhead on all NSObjects
            NSString *className = [NSString stringWithUTF8String:class_getName(class)];
            if (! [className hasPrefix:kSubclassPrefix]) {
                NSString *subclassName = [kSubclassPrefix stringByAppendingString:className];
                Class subclass = NSClassFromString(subclassName);
                if (! subclass) {
                    subclass = objc_allocateClassPair(class, [subclassName UTF8String], 0);
                    NSAssert(subclass != Nil, @"Could not register subclass");
                    class_addMethod(subclass, 
                                    NSSelectorFromString(@"dealloc"),
                                    (IMP)subclass_dealloc, 
                                    method_getTypeEncoding(class_getInstanceMethod(class, NSSelectorFromString(@"dealloc"))));
                    class_addMethod(subclass, 
                                    @selector(class), 
                                    (IMP)subclass_class, 
                                    method_getTypeEncoding(class_getClassMethod(class, @selector(class))));
                    objc_registerClassPair(subclass);
                }
                
                // Changes the object class
                object_setClass(object, subclass);    
            }
            
            // Attach to object a list storing all zeroing weak references pointing at it
            NSMutableSet *zeroingWeakRefValues = objc_getAssociatedObject(object, s_zeroingWeakRefListKey);
            if (! zeroingWeakRefValues) {
                zeroingWeakRefValues = [NSMutableSet set];
                objc_setAssociatedObject(object, s_zeroingWeakRefListKey, zeroingWeakRefValues, OBJC_ASSOCIATION_RETAIN);
            }
            NSValue *selfValue = [NSValue valueWithNonretainedObject:self];
            [zeroingWeakRefValues addObject:selfValue];
        }        
    }
    return self;
}

- (void)dealloc
{
    NSMutableSet *zeroingWeakRefValues = objc_getAssociatedObject(self.object, s_zeroingWeakRefListKey);
    NSValue *selfValue = [NSValue valueWithNonretainedObject:self];
    [zeroingWeakRefValues removeObject:selfValue];
    
    // No weak ref anymore. Can remove the dynamic subclass
    if ([zeroingWeakRefValues count] == 0) {
        Class superclass = class_getSuperclass(object_getClass(self.object));
        object_setClass(self.object, superclass);
    }
}

#pragma mark Optional cleanup

- (void)addInvocation:(NSInvocation *)invocation
{
    [self.invocations addObject:invocation];
}

- (void)addCleanupAction:(SEL)action onTarget:(id)target
{
    NSMethodSignature *methodSignature = [[target class] instanceMethodSignatureForSelector:action];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.target = target;             // NSInvocation not set to retain its arguments here
    invocation.selector = action;
    [self addInvocation:invocation];
}

@end

static void subclass_dealloc(id object, SEL _cmd)
{
    // Set all weak references bound to object to nil
    NSMutableSet *zeroingWeakRefValues = objc_getAssociatedObject(object, s_zeroingWeakRefListKey);
    for (NSValue *zeroingWeakRefValue in zeroingWeakRefValues) {
        HLSZeroingWeakRef *zeroingWeakRef = [zeroingWeakRefValue nonretainedObjectValue];
        
        // Execute optional invocations
        for (NSInvocation *invocation in zeroingWeakRef.invocations) {
            [invocation invoke];
        }
        
        // Zeroing
        zeroingWeakRef.object = nil;
    }
    
    // Call parent implementation
    Class superclass = class_getSuperclass(object_getClass(object));
    void (*parent_dealloc_Imp)(id, SEL) = (void (*)(id, SEL))class_getMethodImplementation(superclass, NSSelectorFromString(@"dealloc"));
    NSCAssert(parent_dealloc_Imp != NULL, @"Could not locate parent dealloc implementation");
    (*parent_dealloc_Imp)(object, _cmd);
}

static Class subclass_class(id object, SEL _cmd)
{
    // Lie about the dynamic subclass existence, as the KVO implementation does (the real class can still be seen
    // using object_getClass)
    return class_getSuperclass(object_getClass(object));
}
