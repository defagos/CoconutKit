//
//  HLSZeroingWeakRef.h
//  CoconutKit
//
//  Created by Samuel Défago on 28.03.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * A weak reference to an object, which gets automatically set to nil when the object it refers to is
 * deallocated. This is a convenient way to eliminate the crashes usually associated with dangling 
 * pointers. Unlike ARC zeroing weak references, though, HLSZeroingWeakRef objects also provide a
 * way to execute custom code before the reference is zeroed. This is especially useful when it makes
 * sense to proactively stop some process whose delegate gets deallocated, for example.
 *
 * HLSZeroingWeakRef instances must be retained by the objects which store them.
 *
 * The current implementation of HLSZeroingWeakRef is fairly basic:
 *   - zeroing weak references to toll-free bridged objects (NSString, NSURL, NSNumber, etc.) are not 
 *     supported. Attempting to initialize a zeroing weak with a toll-free bridged object results in 
 *     an exception being thrown
 *   - thread-safety issues have been ignored
 *
 * This implementation should suffice in most cases (weak pointers to instances of custom Objective-C 
 * classes, accessed from a single thread). In other cases, consider using Mike Ash implementation
 * found at https://github.com/mikeash/MAZeroingWeakRef or ARC zeroing weak references.
 */
@interface HLSZeroingWeakRef : NSObject {
@private
    id m_object;
    NSMutableArray *m_invocations;
}

/**
 * Initialize a weak reference to an Objective-C object (throws an exception if object is a toll-free
 * bridged object)
 */
- (id)initWithObject:(id)object;

/**
 * Return the current object if it is still alive, or nil if the reference has been zeroed
 */
@property (nonatomic, readonly, assign) id object;

/**
 * Optional invocations to be performed just before the weak reference is zeroed. The actions / invocations 
 * are called in the order in which they have been added
 */
- (void)addInvocation:(NSInvocation *)invocation;

/**
 * Optional cleanup actions (with signature - (void)methodName) to be invoked on some target just before
 * the weak reference is zeroed. The target is not retained, and the actions / invocations are called in the
 * order in which they have been added
 */
- (void)addCleanupAction:(SEL)action onTarget:(id)target;

@end
