//
//  HLSRuntime.m
//  CoconutKit
//
//  Created by Samuel Défago on 30.06.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSRuntime.h"

#import "HLSWeakObjectWrapper.h"

/**
 * Remark: Unlike the documentation previously said, protocol_getMethodDescription also takes into account parent protocols
 *         (see http://www.opensource.apple.com/source/objc4/objc4-532.2/runtime/objc-runtime-new.mm)
 */

#import <objc/message.h>

static IMP hls_class_swizzleSelectorCommon(Class clazz, SEL selector, IMP newImplementation);

struct objc_method_description *hls_protocol_copyMethodDescriptionList(Protocol *protocol,
                                                                       BOOL isRequiredMethod,
                                                                       BOOL isInstanceMethod,
                                                                       unsigned int *pCount)
{
    unsigned int numberOfMethodDescriptions = 0;
    struct objc_method_description *methodDescriptions = NULL;
    
    // protocol_copyMethodDescriptionList only returns the methods which the current protocol conforms to (ignoring
    // parent protocols). Climb up the inheritance hierarchy
    unsigned int numberOfProtocolMethodDescriptions = 0;
    struct objc_method_description *protocolMethodDescriptions = protocol_copyMethodDescriptionList(protocol,
                                                                                                    isRequiredMethod,
                                                                                                    isInstanceMethod,
                                                                                                    &numberOfProtocolMethodDescriptions);
    if (protocolMethodDescriptions) {
        methodDescriptions = protocolMethodDescriptions;
        numberOfMethodDescriptions = numberOfProtocolMethodDescriptions;
    }
    
    // Climb up the protocol inheritance hierarchy
    unsigned int numberOfParentProtocols = 0;
    Protocol * __unsafe_unretained * parentProtocols = protocol_copyProtocolList(protocol, &numberOfParentProtocols);
    for (unsigned int i = 0; i < numberOfParentProtocols; ++i) {
        Protocol *parentProtocol = parentProtocols[i];
        unsigned int numberOfParentProtocolMethodDescriptions = 0;
        struct objc_method_description *parentProtocolMethodDescriptions = hls_protocol_copyMethodDescriptionList(parentProtocol,
                                                                                                                  isRequiredMethod,
                                                                                                                  isInstanceMethod,
                                                                                                                  &numberOfParentProtocolMethodDescriptions);
        if (parentProtocolMethodDescriptions) {
            // First method list retrieved. Keep the allocated array we got
            if (numberOfMethodDescriptions == 0) {
                methodDescriptions = parentProtocolMethodDescriptions;
                numberOfMethodDescriptions = numberOfParentProtocolMethodDescriptions;
            }
            // Methods already available. Resize and append by copy, avoiding duplicates, then stretch if duplicates have been found
            else {
                // Work with the largest array we might need
                methodDescriptions = realloc(methodDescriptions,
                                             (numberOfMethodDescriptions + numberOfParentProtocolMethodDescriptions) * sizeof(struct objc_method_description));
                
                unsigned int numberOfNonDuplicateMethodDescriptions = 0;
                for (unsigned int j = 0; j < numberOfParentProtocolMethodDescriptions; ++j) {
                    struct objc_method_description parentProtocolMethodDescription = parentProtocolMethodDescriptions[j];
                    
                    // Search for duplicates. Only need to search in already existing descriptions (those returned by
                    // protocol_copyMethodDescriptionList or hls_protocol_copyMethodDescriptionList are already unique
                    // and do not need to be checked again)
                    BOOL duplicateFound = NO;
                    for (unsigned k = 0; k < numberOfMethodDescriptions; ++k) {
                        // Compare selectors
                        if (parentProtocolMethodDescription.name == methodDescriptions[k].name) {
                            duplicateFound = YES;
                            break;
                        }
                    }
                    
                    // Skip duplicates (if a second selector with a different signature is found, it is dropped)
                    if (duplicateFound) {
                        continue;
                    }
                    
                    methodDescriptions[numberOfMethodDescriptions + numberOfNonDuplicateMethodDescriptions] = parentProtocolMethodDescription;
                    ++numberOfNonDuplicateMethodDescriptions;
                }
                free(parentProtocolMethodDescriptions);
                
                // Shrink the array (if needed)
                if (numberOfNonDuplicateMethodDescriptions != numberOfParentProtocolMethodDescriptions) {
                    methodDescriptions = realloc(methodDescriptions,
                                                 (numberOfMethodDescriptions + numberOfNonDuplicateMethodDescriptions) * sizeof(struct objc_method_description));
                }
                numberOfMethodDescriptions += numberOfNonDuplicateMethodDescriptions;
            }
        }
    }
    free(parentProtocols);
    
    if (pCount) {
        *pCount = numberOfMethodDescriptions;
    }
    return methodDescriptions;
}

BOOL hls_class_conformsToProtocol(Class cls, Protocol *protocol)
{
    Class class = cls;
    while (class != Nil) {
        if (class_conformsToProtocol(class, protocol)) {
            return YES;
        }
        class = class_getSuperclass(class);
    }
    return NO;
}

BOOL hls_class_conformsToInformalProtocol(Class cls, Protocol *protocol)
{
    // Just checks that all required class and instance methods have been implemented
    return hls_class_implementsProtocolMethods(cls, protocol, YES, NO)
        && hls_class_implementsProtocolMethods(cls, protocol, YES, YES);
}

BOOL hls_class_implementsProtocol(Class cls, Protocol *protocol)
{
    // Check that all required and optional class and instance methods have been implemented
    return hls_class_implementsProtocolMethods(cls, protocol, YES, NO)
        && hls_class_implementsProtocolMethods(cls, protocol, NO, NO)
        && hls_class_implementsProtocolMethods(cls, protocol, YES, YES)
        && hls_class_implementsProtocolMethods(cls, protocol, NO, YES);
}

BOOL hls_class_implementsProtocolMethods(Class cls, Protocol *protocol, BOOL isRequiredMethod, BOOL isInstanceMethod)
{
    unsigned int numberOfMethods = 0;
    struct objc_method_description *methodDescriptions = hls_protocol_copyMethodDescriptionList(protocol,
                                                                                                isRequiredMethod,
                                                                                                isInstanceMethod,
                                                                                                &numberOfMethods);
    
    BOOL result = YES;
    for (unsigned int i = 0; i < numberOfMethods; ++i) {
        struct objc_method_description methodDescription = methodDescriptions[i];
        SEL selector = methodDescription.name;
        
        // This searches in superclasses as well
        Method method = isInstanceMethod ? class_getInstanceMethod(cls, selector) : class_getClassMethod(cls, selector);
        if (! method) {
            result = NO;
            break;
        }
        
        // Check method signature consistency
        if (strcmp(method_getTypeEncoding(method), methodDescription.types) != 0) {
            result = NO;
            break;
        }
        
    }
    free(methodDescriptions);
    
    return result;
}

/**
 * About method swizzling in class hierarchies: 
 * --------------------------------------------
 *
 * Consider the -awakeFromNib method. This method is defined at the NSObject level (in a category) and might be
 * implemented by subclasses. UIView, which is an NSObject subclass, does not implement -awakeFromNib itself.
 * When calling -[UIView awakeFromNib], it is therefore the NSObject implementation (which does nothing) which
 * gets called. Similarly, UILabel is a UIView subclass which does not implement -awakeFromNib.
 *
 * Now imagine we swizzle -awakeFromNib both at the UIView and UILabel levels, just by getting the original
 * implementation (in both cases the one of NSObject since neither UIView nor UILabel actually override
 * -awakeFromNib) and calling class_replaceMethod. When swizzling the methods, we take care of storing pointers
 * to the original implementations. In each of the swizzled method implementations, we can then call the original
 * implementation, so that the original behavior is preserved. Seems correct and safe.
 *
 * What happens now when -awakeFromNib is called on a UIView instance? Well, everything works as expected: The swizzled
 * method implementation gets called, and in turns calls the original implementation we have replaced (the one at the
 * NSObject level).
 *
 * Is everything also working as expected when -awakeFromNib is called on a UILabel instance? The answer is no. Well, 
 * of course the UILabel swizzled method implementation gets called, which in turns calls the original implementation
 * we have replaced (the one at the NSObject level). But the swizzled -[UIView awakeFromNib] method never gets called.
 * The reason is obvious: Since UILabel did not actually implement -awakeFromNib before we swizzled it, its original
 * method implementation did not call the super implementation.
 *
 * How can we solve this issue? The obvious answer is to call -[super awakeFromNib] from within the swizzled
 * UILabel method implementation, but this requires some knowledge about the original behavior, which can be
 * a problem, should this behavior change in the future (especially for classes which we cannot control the
 * the implementation of). Can we do better?
 *
 * Well, we can. Assume that SomeClass implements -aMethod. If SomeSubclass is a subclass of SomeClass, then
 * we have three possible cases:
 *
 * 1) SomeSubclass implements -aMethod and calls [super aMethod] from within its implementation: After swizzling
 *    of -[SomeSubclass aMethod], and provided the original implementation is called, the SomeClass implementation
 *    of -aMethod will be called when -[SomeSubclass aMethod] gets called. If -[SomeClass aMethod] gets swizzled as
 *    well, then all swizzled method implementations will be called. The behavior is therefore correct without any 
 *    additional measures
 * 2) SomeSubclass implements -aMethod but does not call [super aMethod] on purpose (to replace it): After swizzling of
 *    -[SomeSubclass aMethod], the SomeClass implementation of -aMethod will not be called when -[SomeSubclass aMethod]
 *    gets called. The behavior is therefore also correct in this case
 * 3) SomeSubclass does not implement -aMethod: Before swizzling of -[SomeSubclass aMethod], when calling -aMethod
 *    on a SomeSubclass instance, the -[SomeClass aMethod] implementation gets called. If -[SomeClass aMethod] has
 *    been swizzled, the swizzled implementation will be called. After swizzling of -[SomeSubclass aMethod], when
 *    calling -aMethod on a SomeSubclass instance, then -[SomeClass aMethod] will not be called anymore, because 
 *    [super aMethod] is never called within -[SomeSubclass aMethod] implementation. Any prior swizzling of 
 *    -[SomeClass aMethod] is therefore lost when calling -[SomeSubclass aMethod]
 *
 * The solution to 3) should now be obvious: Since having a method implementation guarantees correct behavior (see 1) and
 * 2)), the rule is never to swizzle a method on a class which does not implement it itself. If the class does not implement
 * the method itself, and if we want to swizzle it, we must therefore add the method at runtime first. In order for the
 * parent implementation to be called first (so that the behavior stays consistent with the situation prior to swizzling),
 * the added method implementation must consist of a single call to the super method implementation.
 *
 * Remark:
 * -------
 * Method swizzling is usually made by having two method implementations being exchanged (see e.g. JRSwizzle). In such
 * cases we must only ensure that the swizzled method exists, correct behavior is guaranteed since calling the original
 * implementation is then made using standard Objective-C messaging. Swizzling by setting an IMP without associated
 * selector, as done here, is therefore somewhat trickier, but is robust against swizzled method name clashes
 */

IMP hls_class_swizzleClassSelector(Class clazz, SEL selector, IMP newImplementation)
{
    return hls_class_swizzleSelectorCommon(objc_getMetaClass(class_getName(clazz)), selector, newImplementation);
}

IMP hls_class_swizzleSelector(Class clazz, SEL selector, IMP newImplementation)
{
    return hls_class_swizzleSelectorCommon(clazz, selector, newImplementation);
}

static IMP hls_class_swizzleSelectorCommon(Class clazz, SEL selector, IMP newImplementation)
{
    // Calling class_getInstanceMethod on a metaclass is the same as calling class_getClassMethod on the class itself. There
    // is therefore no need to test whether the class is a metaclass or not! Lookup is performed in parent classes as well
    Method method = class_getInstanceMethod(clazz, selector);
    if (! method) {
        // Cannot swizzle methods which are not implemented by the class or one of its parents
        return NULL;
    }
    
    // The following only adds a method implementation if the class does not implement it itself (block implementations
    // sigatures must not have a SEL argument). The added method only calls the super counterpart, see explanation above
    const char *types = method_getTypeEncoding(method);
    class_addMethod(clazz, selector, imp_implementationWithBlock(^(__unsafe_unretained id self /* prevent incorrect ARC memory calls */, va_list argp) {
        struct objc_super super = {
            .receiver = self,
            .super_class = class_getSuperclass(clazz)
        };
        
        // Cast the call to objc_msgSendSuper appropriately
        id (*objc_msgSendSuper_typed)(struct objc_super *, SEL, va_list) = (void *)&objc_msgSendSuper;
        return objc_msgSendSuper_typed(&super, selector, argp);
    }), types);
    
    // Swizzling
    return class_replaceMethod(clazz, selector, newImplementation, types);
}

IMP hls_class_swizzleClassSelector_block(Class clazz, SEL selector, id newImplementationBlock)
{
    IMP newImplementation = imp_implementationWithBlock(newImplementationBlock);
    return hls_class_swizzleClassSelector(clazz, selector, newImplementation);
}

IMP hls_class_swizzleSelector_block(Class clazz, SEL selector, id newImplementationBlock)
{
    IMP newImplementation = imp_implementationWithBlock(newImplementationBlock);
    return hls_class_swizzleSelector(clazz, selector, newImplementation);
}

BOOL hls_class_isSubclassOfClass(Class subclass, Class superclass)
{
    for (Class class = subclass; class != Nil; class = class_getSuperclass(class)) {
        if (class == superclass) {
            return YES;
        }
    }
    return NO;
}

BOOL hls_isClass(id object)
{
    return class_isMetaClass(object_getClass(object));
}

void hls_object_replaceReferencesToObject(id object, id replacedObject, id replacingObject)
{
    unsigned int numberOfIvars = 0;
    Ivar *ivars = class_copyIvarList([object class], &numberOfIvars);
    for (unsigned int i = 0; i < numberOfIvars; ++i) {
        Ivar ivar = ivars[i];
        
        // Check type encoding first
        // Remark: Without proper casting, calling ivar_getName on ivar storing a primitive type can lead to crashes due
        //         to ncorrect ARC memory management. This is not an issue here since this function is restricted to ivars
        // storing objects
        if (*ivar_getTypeEncoding(ivar) != *@encode(id)) {
            continue;
        }
        
        // Replace the object
        if (object_getIvar(object, ivar) == replacedObject) {
            object_setIvar(object, ivar, replacingObject);
        }
    }
    free(ivars);
}

void hls_setAssociatedObject(id object, const void *key, id value, hls_AssociationPolicy policy)
{
    // Use an indirection so that associated objects attached using hls_setAssociatedObject can only be retrieved
    // using hls_getAssociatedObject, not using objc_getAssociatedObject. Conversely, associated objects created
    // using objc_setAssociatedObject cannot be retrieved using hls_getAssociatedObject
    void *hiddenKey = (void *)[[NSString stringWithFormat:@"hls_%p", key] hash];
    if (policy == HLS_ASSOCIATION_WEAK || policy == HLS_ASSOCIATION_WEAK_NONATOMIC) {
        objc_AssociationPolicy objc_policy = (policy == HLS_ASSOCIATION_WEAK) ? OBJC_ASSOCIATION_RETAIN : OBJC_ASSOCIATION_RETAIN_NONATOMIC;
        
        HLSWeakObjectWrapper *weakObjectWrapper = [[HLSWeakObjectWrapper alloc] initWithObject:value];
        objc_setAssociatedObject(object, hiddenKey, weakObjectWrapper, objc_policy);
    }
    else {
        objc_setAssociatedObject(object, hiddenKey, value, policy);
    }
}

id hls_getAssociatedObject(id object, const void *key)
{
    // See hls_setAssociatedObject
    void *hiddenKey = (void *)[[NSString stringWithFormat:@"hls_%p", key] hash];
    id associatedObject = objc_getAssociatedObject(object, hiddenKey);
    if ([associatedObject isKindOfClass:[HLSWeakObjectWrapper class]]) {
        HLSWeakObjectWrapper *weakObjectWrapper = (HLSWeakObjectWrapper *)associatedObject;
        return weakObjectWrapper.object;
    }
    else {
        return associatedObject;
    }
}
