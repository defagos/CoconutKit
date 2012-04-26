//
//  HLSProtocolProxy.h
//  CoconutKit
//
//  Created by Samuel Défago on 25.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

// Forward declarations
@class HLSZeroingWeakRef;

/**
 * HLSProtocolProxy allows the easy creation of lightweight proxy objects through which interaction with the 
 * underlying object only happens through a restricted subset of its class interface. The common restricted 
 * interface subset is determined by moving its methods to a protocol which the class must implement.
 *
 * Without HLSProtocolProxy, you can still use a protocol to factor out a restricted interface from an object, have 
 * this object implement this protocol, and return the object as id<protocol> where you want clients to act on it 
 * using the restricted interface. The drawback is that nothing prevents clients from accidentally or purposely 
 * casting the object into its original class (in which case they will still be able to use the full object interface).
 *
 * HLSProtocolProxy allows you to create an indirection level which makes it impossible to accidentally cast
 * the object so that its full interface can be accessed.
 *
 * The proxy object does not retain the object it is created from. If the object gets deallocated, all associated
 * proxy objects are automatically set to nil.
 *
 * TODO: the target could be a proxy as well (refinement)
 */
@interface HLSProtocolProxy : NSProxy {
@private
    HLSZeroingWeakRef *_targetZeroingWeakRef;
    Protocol *_protocol;
}

/**
 * Convenience constructor
 */
+ (id)proxyWithTarget:(id)target protocol:(Protocol *)protocol;

/**
 * Create a proxy object. On success a proxy object is returned, otherwise nil. The proxy object conforms to the
 * same protocol, you should therefore store the result as id<protocol> for further compiler-friendly use
 */
- (id)initWithTarget:(id)target protocol:(Protocol *)protocol;

@end
