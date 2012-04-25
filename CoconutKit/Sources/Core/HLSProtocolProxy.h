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
 * We often encounter classes which have slightly different interfaces but which are otherwise similar.
 * A common example is a mutable class which differs from its immutable class counterpart by the
 * ability to mutate some of its attributes. If we want to implement such classes, we have several
 * options:
 *   - create the immutable class interface, and an associated Friend category which collects all mutators.
 *     The class interface itself must contain creation and accessor methods only. In the class .m implementation 
 *     file, and from any other source file which requires the ability to mutate the object, include the Friend 
 *     category header file to access the whole interface. Clients which only need to interact with the object 
 *     in a mutable way include the class header file only. This way the compiler will report unknown method
 *     calls if a client tries to call some mutator on the class when only the class header file has been included
 *   - make the immutable class inherit from the mutable class, and enrich its interface with mutators. In
 *     such cases, though, the subclass must still implement the mutators, usually by calling mutator methods
 *     which the immutable class must secretly provide (using private Friend header files is a way to achieve 
 *     this). Where a mutable object must be accessed in an immutable way, we simply return the mutable object, 
 *     cast to its immutable counterpart. This is of course dangerous since callers might be tempted to cast this
 *     object back to its original mutable identity
 *   - provide a method to create an immutable copy from a mutable object. This requires a lot of boilerplate
 *     code just to copy the internal data of the mutable object into the immutable one. This also requires
 *     both classes to implement the accessors needed to read the data. Moreover, we obtain a data
 *     snapshot, the immutable object will stay the same as the mutable one changes
 *
 * In the first case, all the implementation resides in the immutable class .m file. In the second case,
 * some code must be written in the mutable class .m file as well. In the third case, most code must be
 * duplicated.
 *
 * HLSProtocolProxy offers a fourth way of elegantly solving this problem: The immutable methods common to
 * both classes are collected in a protocol whose methods must all be optional. Two separate classes must 
 * then be created, conforming to this common contract:
 *   - the mutable class, which contains the implementation of all methods (accessors and mutators), and
 *     which declare mutators in its interface (those are added to the methods declared in the protocol
 *     to create the full mutable class interface)
 *   - a subclass of the abstract HLSProtocolProxy class. The subclass does not require any implementation 
 *     (in fact it must not be implemented at all, otherwise the behavior is undefined) and only offers
 *     immutable access to the underyling object
 *
 * The goal of the HLSProtocolProxy subclass is only to forward the calls to the methods declared by the common
 * protocol transparently to the immutable implementation. This way, we directly access the mutable object,
 * but in an immutable way. If the mutable object changes, we transparently access its updated data through
 * the immutable proxy subclass. No additional code is required.
 *
 * All protocol methods must be optional so that the proxy subclass does not require any implementation
 * (having required methods would be better, but this would lead to compiler warnings, though everything
 * would work fine at runtime. I could not find a way to inhibit such warnings, though).
 *
 * Of course, the use of HLSProtocolProxy is by no means limited to mutable and immutable classes. In general,
 * you can use an HLSProtocolProxy when you want to restrict interaction with an existing class. The proxy class
 * has is only there to expose a restricted interface.
 *
 * The common contract between original and proxy classes can be defined using several protocols if needed.
 * All that is required is that the original class at least conforms to all protocols the proxy class conforms
 * to. If an incompatibilty is detected, a proxy cannot be created.
 *
 * Instantiating an HLSProtocolProxy object is a lightweight process. Compatibility between classes and their
 * proxy counterparts is performed once and cached. The method call overhead is also minimal since the proxy object 
 * only forwards calls to the original object, nothing more.
 *
 * The proxy object does not retain the object it is created from. If the object gets deallocated, all associated
 * proxy objects are automatically set to nil.
 *
 * Designated initializer: initWithTarget:
 */
@interface HLSProtocolProxy : NSProxy {
@private
    HLSZeroingWeakRef *_targetZeroingWeakRef;
}

/**
 * Convenience constructor
 */
+ (id)proxyWithTarget:(id)target;

/**
 * Create a proxy for a given target. Creation fails if the protocols implemented by both classes are not
 * compatible
 */
- (id)initWithTarget:(id)target;

@end
