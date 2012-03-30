//
//  HLSZeroingWeakRef.m
//  CoconutKit
//
//  Created by Samuel Défago on 28.03.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSZeroingWeakRef.h"

#import <objc/runtime.h>
#import "NSObject+HLSExtensions.h"

// Associated object keys
static void *s_zeroingWeakRefListKey = &s_zeroingWeakRefListKey;

static void subclass_dealloc(id object, SEL _cmd);

@interface HLSZeroingWeakRef ()

@property (nonatomic, assign) id object;
@property (nonatomic, retain) NSMutableArray *invocations;

@end

@implementation HLSZeroingWeakRef

#pragma mark Object creation and destruction

- (id)initWithObject:(id)object
{
    if ((self = [super init])) {
        static NSString * const kSubclassPrefix = @"HLSZeroingWeakRef_";
        
        self.object = object;
        self.invocations = [NSMutableArray array];
        
        // Dynamically subclass the object class to override -dealloc selectively (swizzling -dealloc at the NSObject
        // level is NOT an option)
        NSString *className = [object className];
        if (! [className hasPrefix:kSubclassPrefix]) {
            NSString *subclassName = [kSubclassPrefix stringByAppendingString:className];
            Class subclass = NSClassFromString(subclassName);
            if (! subclass) {
                subclass = objc_allocateClassPair([object class], [subclassName UTF8String], 0);
                NSAssert(subclass != Nil, @"Could not register subclass");
                class_addMethod(subclass, @selector(dealloc), (IMP)subclass_dealloc, "v@:");
                objc_registerClassPair(subclass);
            }
            
            // Changes the object class
            object_setClass(object, subclass);    
        }
        
        // Attach to object a list storing all weak references pointing at it
        NSMutableSet *zeroingWeakRefValues = objc_getAssociatedObject(object, s_zeroingWeakRefListKey);
        if (! zeroingWeakRefValues) {
            zeroingWeakRefValues = [NSMutableSet set];
            objc_setAssociatedObject(object, s_zeroingWeakRefListKey, zeroingWeakRefValues, OBJC_ASSOCIATION_RETAIN);
        }
        NSValue *selfValue = [NSValue valueWithPointer:self];
        [zeroingWeakRefValues addObject:selfValue];
    }
    return self;
}

- (void)dealloc
{
    NSMutableSet *zeroingWeakRefValues = objc_getAssociatedObject(self.object, s_zeroingWeakRefListKey);
    NSValue *selfValue = [NSValue valueWithPointer:self];
    [zeroingWeakRefValues removeObject:selfValue];
    
    self.object = nil;
    self.invocations = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize object = m_object;

@synthesize invocations = m_invocations;

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
    // Update the weak references
    NSMutableSet *zeroingWeakRefValues = objc_getAssociatedObject(object, s_zeroingWeakRefListKey);
    for (NSValue *zeroingWeakRefValue in zeroingWeakRefValues) {
        HLSZeroingWeakRef *zeroingWeakRef = [zeroingWeakRefValue pointerValue];
        
        // Execute optional invocations
        for (NSInvocation *invocation in zeroingWeakRef.invocations) {
            [invocation invoke];
        }
        
        // Zeroing
        zeroingWeakRef.object = nil;
    }
    
    // Call parent implementation
    void (*parent_dealloc_Imp)(id, SEL) = (void (*)(id, SEL))class_getMethodImplementation([object superclass], @selector(dealloc));
    NSCAssert(parent_dealloc_Imp != NULL, @"Could not locate parent dealloc implementation");
    (*parent_dealloc_Imp)(object, _cmd);
}
