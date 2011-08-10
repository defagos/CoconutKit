//
//  HLSAssert.h
//  CoconutKit
//
//  Created by Samuel Défago on 7/14/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * The following macros are only active if NS_BLOCK_ASSERTIONS is disabled for the project configuration you use
 * (usually -DNS_BLOCK_ASSERTIONS=1)
 */
#ifndef NS_BLOCK_ASSERTIONS

/**
 * Assertion at compile time
 *
 * Remark: Using a typedef avoids "unused variable" warnings, and enclosing within a block avoids "type redefinition" errors
 */
#define HLSStaticAssert(expr)                   {typedef char static_assertion_failure[(expr) ? 1 : -1];}

/**
 * Insert this macro in the implementation of a method which is inherited but does not have any meaning for the class
 * you are implementing. This can e.g. be helpful to disable the init NSObject inherited method (which sometimes is
 * not meaningful)
 */
#define HLSForbiddenInheritedMethod()            NSAssert(NO, @"Forbidden inherited method call. This method has "      \
                                                               "been inherited from a parent class but could not "      \
                                                               "be meaningfully overridden. It cannot therefore "       \
                                                               "be called")

/**
 * Insert this macro in methods which must be implemented. This can be useful in the following cases:
 *   - during development, to mark methods you have not implemented yet (but which must be)
 *   - in class design: to mark methods for which a class cannot provide a meaningful implementation, which must be
 *                      supplied in subclasses (abstract class, e.g. the draw method of a Shape class)
 */
#define HLSMissingMethodImplementation()         NSAssert(NO, @"Missing method implementation")

/**
 * The following macros check the type of objects in a collection. Useful for a class to verify that a collection it 
 * receives from a client through its public interface contains objects of the expected type. HLSAssert... macros can 
 * be used in methods only. In C-functions use the HLSCAssert... macros instead.
 *
 * Example: HLSAssertObjectsInEnumerationAreKindOfClass(views, UIScrollView);
 */
#define HLSAssertObjectsInEnumerationAreKindOfClass(enumeration, objectClassName)                                           \
    [[NSAssertionHandler currentHandler] handleIncorrectObjectClass:[objectClassName class]                                 \
                                                      inEnumeration:enumeration                                             \
                                                             strict:NO                                                      \
                                                           inMethod:_cmd                                                    \
                                                             object:self                                                    \
                                                              file:[NSString stringWithUTF8String:__FILE__]                 \
                                                        lineNumber:__LINE__]

#define HLSCAssertObjectsInEnumerationAreKindOfClass(enumeration, objectClassName)                                          \
    [[NSAssertionHandler currentHandler] handleIncorrectObjectClass:[objectClassName class]                                 \
                                                      inEnumeration:enumeration                                             \
                                                             strict:NO                                                      \
                                                         inFunction:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]     \
                                                               file:[NSString stringWithUTF8String:__FILE__]                \
                                                         lineNumber:__LINE__]

#define HLSAssertObjectsInEnumerationAreMembersOfClass(enumeration, objectClassName)                                        \
    [[NSAssertionHandler currentHandler] handleIncorrectObjectClass:[objectClassName class]                                 \
                                                      inEnumeration:enumeration                                             \
                                                             strict:YES                                                     \
                                                           inMethod:_cmd                                                    \
                                                             object:self                                                    \
                                                               file:[NSString stringWithUTF8String:__FILE__]                \
                                                         lineNumber:__LINE__]

#define HLSCAssertObjectsInEnumerationAreMembersOfClass(enumeration, objectClassName)                                       \
    [[NSAssertionHandler currentHandler] handleIncorrectObjectClass:[objectClassName class]                                 \
                                                      inEnumeration:enumeration                                             \
                                                            strict:YES                                                      \
                                                        inFunction:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]      \
                                                              file:[NSString stringWithUTF8String:__FILE__]                 \
                                                        lineNumber:__LINE__]

#else

#define HLSStaticAssert(expr)

#define HLSForbiddenInheritedMethod()
#define HLSMissingMethodImplementation()

#define HLSAssertObjectsInEnumerationAreKindOfClass(enumeration, objectClass)
#define HLSCAssertObjectsInEnumerationAreKindOfClass(enumeration, objectClass)

#define HLSAssertObjectsInEnumerationAreMembersOfClass(enumeration, objectClass)
#define HLSCAssertObjectsInEnumerationAreMembersOfClass(enumeration, objectClass)

#endif

@interface NSAssertionHandler (HLSAssert)

/**
 * Check the class of objects in a collection and generate an assertion on mismatch. If strict is set to YES, all objects
 * must be members of the class which is provided, otherwise they must be connected to it via inheritance
 */
- (void)handleIncorrectObjectClass:(Class)objectClass 
                     inEnumeration:(id<NSFastEnumeration>)enumeration
                            strict:(BOOL)strict 
                          inMethod:(SEL)selector 
                            object:(id)object 
                              file:(NSString *)fileName 
                        lineNumber:(NSInteger)line;
- (void)handleIncorrectObjectClass:(Class)objectClass 
                     inEnumeration:(id<NSFastEnumeration>)enumeration
                            strict:(BOOL)strict 
                        inFunction:(NSString *)functionName 
                              file:(NSString *)fileName 
                        lineNumber:(NSInteger)line;

@end
