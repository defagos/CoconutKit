//
//  HLSRestrictedInterfaceProxy.h
//  CoconutKit
//
//  Created by Samuel Défago on 25.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

// Forward declarations
@class HLSZeroingWeakRef;

/**
 * HLSRestrictedInterfaceProxy allows the easy creation of lightweight proxy objects through which interaction 
 * with the underlying object only happens through a restricted subset of its class interface. The restricted
 * interface subset is defined using a protocol.
 *
 * When creating a proxy object, a protocol informally compatible with the target class must be provided. By 
 * informally we mean that the target class must implement at least all methods @required by the protocol.
 *
 * The proxy object introduces an additionaly safety indirection layer in comparison to the brute-force approach
 * of C-casting to id<RestrictedProtocol>. This approach works but makes it easy to cast the object back to its
 * original identity (either by mistake or on purpose), allowing access to the unrestricted interface.
 *
 * The proxy object does not retain the object it is created from, and if the object gets deallocated, all 
 * associated proxy objects are automatically set to nil.
 *
 * TODO: the target could be a proxy as well (refinement through several proxy levels)
 */
@interface HLSRestrictedInterfaceProxy : NSProxy {
@private
    HLSZeroingWeakRef *_targetZeroingWeakRef;
    Protocol *_protocol;
}

/**
 * Convenience constructor
 */
+ (id)proxyWithTarget:(id)target protocol:(Protocol *)protocol;

/**
 * Create a proxy object. On success a proxy object is returned, otherwise nil. The created proxy object 
 * conforms to the protocol given as parameter, you should therefore store the result as id<protocol> for 
 * further compiler-friendly use
 */
- (id)initWithTarget:(id)target protocol:(Protocol *)protocol;

@end
