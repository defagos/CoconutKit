//
//  HLSRuntime.h
//  CoconutKit
//
//  Created by Samuel Défago on 30.06.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import <objc/runtime.h>

/**
 * Policies for associated objects
 */
typedef NS_ENUM(uintptr_t, hls_AssociationPolicy) {
    HLS_ASSOCIATION_ASSIGN = OBJC_ASSOCIATION_ASSIGN,
    HLS_ASSOCIATION_STRONG_NONATOMIC = OBJC_ASSOCIATION_RETAIN_NONATOMIC,
    HLS_ASSOCIATION_COPY_NONATOMIC = OBJC_ASSOCIATION_COPY_NONATOMIC,
    HLS_ASSOCIATION_STRONG = OBJC_ASSOCIATION_RETAIN,
    HLS_ASSOCIATION_COPY = OBJC_ASSOCIATION_COPY,
    HLS_ASSOCIATION_WEAK,
    HLS_ASSOCIATION_WEAK_NONATOMIC
};

/**
 * Enable or disable logging of the messages sent through objc_msgSend. Messages are logged to
 *    /tmp/msgSends-XXXX
 * with the following format:
 *    <Receiver object class> <Class which implements the method> <Selector name>
 *
 * Remark:
 * This is a function secretely implemented by the Objective-C runtime, not by CoconutKit. The declaration 
 * is here only provided for convenience
 */
void instrumentObjcMessageSends(BOOL start);

/**
 * Return the list of method descriptions a protocol or one of its parent protocols declares. This
 * is similar to protocol_copyMethodDescriptionList, but taking parent protocols into account. A
 * method with a given name is returned at most once in the list (even if it is declared by several
 * protocols along the hierarchy). If two methods with different signatures appear within the
 * hierarchy (which should not happen since this is clearly an error), which one is returned is
 * undefined.
 *
 * The list of method descriptions this function returns must later be freed by calling free()
 */
struct objc_method_description *hls_protocol_copyMethodDescriptionList(Protocol *protocol,
                                                                       BOOL isRequiredMethod,
                                                                       BOOL isInstanceMethod,
                                                                       unsigned int *pCount);

/**
 * Return YES iff the class or one of its superclasses conforms to the given protocol. This
 * is similar to class_conformsToProtocol, but taking superclasses into account. As for
 * class_conformsToProtocol, conformance is tested strictly, i.e. the protocol must be
 * explicitly declared in the @interface of the class or of one of its superclasses
 *
 * Remark: The fact that class_conformsToProtocol does not take superclasses into account
 *         is currently not documented
 */
BOOL hls_class_conformsToProtocol(Class cls, Protocol *protocol);

/**
 * Return YES iff the class informally conforms to a protocol, i.e. if it implements all of its
 * @required methods, including those declared by parent protocols (without the need for the
 * protocol to be declared in the class @interface).
 *
 * Remark: If a class formally conforms to a protocol it automatically informally conforms to
 *         it as well. The converse is not true
 */
BOOL hls_class_conformsToInformalProtocol(Class cls, Protocol *protocol);

/**
 * Return YES iff the class implements all @optional and @required methods of a given protocol
 * and of its parent protocols (whether the class formally or only informally conforms to the
 * protocol is irrelevant). This method also takes superclasses into account
 */
BOOL hls_class_implementsProtocol(Class cls, Protocol *protocol);

/**
 * Check that a class (taking into account its superclasses) implements methods of a given protocol,
 * taking into account methods defined by parent protocols. Two boolean values control which methods
 * are checked:
 *   - isRequiredMethod: If YES, checks @required methods only, otherwise @optional methods only
 *   - isInstanceMethod: If YES, checks instance methods only, otherwise class methods only
 */
BOOL hls_class_implementsProtocolMethods(Class cls, Protocol *protocol, BOOL isRequiredMethod, BOOL isInstanceMethod);

/**
 * Replace the implementation of a class method, given its selector. Return the original implementation,
 * or NULL if not found. You should save the original implementation pointer somewhere and call it from
 * the new implementation to preserve existing behavior. When calling the original implenentation, be sure 
 * to cast the IMP pointer to the proper signature (the first arguments of a method implementation signature 
 * are always self (of type id) and the selector (of type SEL), followed by the method arguments
 */
IMP hls_class_swizzleClassSelector(Class clazz, SEL selector, IMP newImplementation);

/**
 * Replace the implementation of an instance method, given its selector. Return the original implementation,
 * or NULL if not found. You should save the original implementation pointer somewhere and call it from
 * the new implementation to preserve existing behavior. When calling the original implenentation, be sure
 * to cast the IMP pointer to the proper signature (the first arguments of a method implementation signature
 * are always self (of type id) and the selector (of type SEL), followed by the method arguments
 */
IMP hls_class_swizzleSelector(Class clazz, SEL selector, IMP newImplementation);

/**
 * Replace the implementation of a class method using the provided implementation block (see imp_implementationWithBlock
 * documemtation for information about valid block signatures). Return the original implementation, or NULL if not found. 
 * You should store this original implementation in a __block variable and call it from the implementation block to
 * preserve existing behavior
 */
IMP hls_class_swizzleClassSelector_block(Class clazz, SEL selector, id newImplementationBlock);

/**
 * Replace the implementation of an instance method using the provided implementation block (see imp_implementationWithBlock
 * documemtation for information about valid block signatures). Return the original implementation, or NULL if not found. 
 * You should store this original implementation in a __block variable and call it from the implementation block to
 * preserve existing behavior
 */
IMP hls_class_swizzleSelector_block(Class clazz, SEL selector, id newImplementationBlock);

/**
 * Return YES iff subclass is a subclass of superclass, or if subclass == superclass (in agreement with
 * the behavior of +[NSObject isSubclassOfClass:])
 */
BOOL hls_class_isSubclassOfClass(Class subclass, Class superclass);

/**
 * Return YES iff object is a class object
 */
BOOL hls_isClass(id object);

/**
 * Replace all references to an object (replaced object), appearing in an object (object), by references to another object
 * (replacingObject)
 */
void hls_object_replaceReferencesToObject(id object, id replacedObject, id replacingObject);

/**
 * Same as objc_setAssociatedObject, but with support for weak references. Objects associated using hls_setAssociatedObject
 * can only be retrieved using hls_getAssociatedObject, not using objc_getAssociatedObject
 */
void hls_setAssociatedObject(id object, const void *key, id value, hls_AssociationPolicy policy);

/**
 * Same as objc_setAssociatedObject, but with support for weak references. Only retrieves objects associated using
 * hls_setAssociatedObject, not objc_setAssociatedObject
 */
id hls_getAssociatedObject(id object, const void *key);
