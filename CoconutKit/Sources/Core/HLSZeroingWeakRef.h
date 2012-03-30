//
//  HLSZeroingWeakRef.h
//  CoconutKit
//
//  Created by Samuel Défago on 28.03.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

// Document: Must be retained
// TODO: Instead of adding actions, we could add NSInvocation objects (then implement addTarget:action:
//       using invocations in the simplest case)
@interface HLSZeroingWeakRef : NSObject {
@private
    id m_object;
    NSMutableArray *m_invocations;
}

/**
 * Initialize a weak reference to an object. When object gets deallocated, the weak reference object
 * is automatically set to nil
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
 * Optional cleanup actions (with signature -(void)methodName) to be invoked on some target just before
 * the weak reference is zeroed. The target is not retained, and the actions / invocations are called in the
 * order in which they have been added
 */
- (void)addCleanupAction:(SEL)action onTarget:(id)target;

@end
