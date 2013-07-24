//
//  HLSRuntime.h
//  CoconutKit
//
//  Created by Samuel Défago on 30.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import <objc/runtime.h> 

/**
 * The following methods can be safely used in pure C code
 *
 * Remark: Unlike the documentation says, protocol_getMethodDescription also takes into account parent protocols
 *         (see http://www.opensource.apple.com/source/objc4/objc4-532.2/runtime/objc-runtime-new.mm). There is
 *         therefore no need for an hls_protocol_getMethodDescription function
 */

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
 * Check that a class (taking into account its superclasses) implements methods of a given protocol
 * (taking into account methods defined by parent protocols). Two boolean values control which methods
 * are checked:
 *   - isRequiredMethod: If YES, checks @required methods only, otherwise @optional methods only
 *   - isInstanceMethod: If YES, checks instance methods only, otherwise class methods only
 */
BOOL hls_class_implementsProtocolMethods(Class cls, Protocol *protocol, BOOL isRequiredMethod, BOOL isInstanceMethod);

/**
 * Replace the implementation of a class method, given its selector. Return the original implementation,
 * or NULL if not found
 */
IMP hls_class_swizzleClassSelector(Class clazz, SEL selector, IMP newImplementation);

/**
 * Replace the implementation of an instance method, given its selector. Return the original implementation,
 * or NULL if not found
 */
IMP hls_class_swizzleSelector(Class clazz, SEL selector, IMP newImplementation);

/**
 * Return YES iff subclass is a subclass of superclass, or if subclass == superclass (in agreement with
 * the behavior of +[NSObject isSubclassOfClass:])
 */
BOOL hls_class_isSubclassOfClass(Class subclass, Class superclass);
