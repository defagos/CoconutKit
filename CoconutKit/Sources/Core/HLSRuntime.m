//
//  HLSRuntime.m
//  CoconutKit
//
//  Created by Samuel Défago on 30.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSRuntime.h"

#import "stdlib.h"

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
        numberOfMethodDescriptions += numberOfProtocolMethodDescriptions;
    }
    
    unsigned int numberOfParentProtocols = 0;
    Protocol **parentProtocols = protocol_copyProtocolList(protocol, &numberOfParentProtocols);
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
            }
            // Methods already available. Resize and append by copy
            else {
                methodDescriptions = realloc(methodDescriptions, 
                                             (numberOfMethodDescriptions + numberOfParentProtocolMethodDescriptions) * sizeof(struct objc_method_description));
                for (unsigned int j = 0; j < numberOfParentProtocolMethodDescriptions; ++j) {
                    methodDescriptions[numberOfMethodDescriptions + j] = parentProtocolMethodDescriptions[j]; 
                }
                free(parentProtocolMethodDescriptions);
            }
            numberOfMethodDescriptions += numberOfParentProtocolMethodDescriptions;
        }
    }
    free(parentProtocols);
    
    // TODO: Remove duplicates; warn on conflict
    
    if (pCount) {
        *pCount = numberOfMethodDescriptions;
    }
    return methodDescriptions;
}

BOOL hls_class_conformsToProtocol(Class cls, Protocol *protocol)
{
    Class class = cls;
    while (class) {
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
        Method method = class_getInstanceMethod(cls, selector);
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

IMP HLSSwizzleClassSelector(Class cls, SEL selector, IMP newImplementation)
{
    // Get the original implementation we are replacing
    Class metaClass = objc_getMetaClass(class_getName(cls));
    Method method = class_getClassMethod(metaClass, selector);
    IMP origImp = method_getImplementation(method);
    if (! origImp) {
        return NULL;
    }
    
    class_replaceMethod(metaClass, selector, newImplementation, method_getTypeEncoding(method));
    return origImp;
}

IMP HLSSwizzleSelector(Class cls, SEL selector, IMP newImplementation)
{
    // Get the original implementation we are replacing
    Method method = class_getInstanceMethod(cls, selector);
    IMP origImp = method_getImplementation(method);
    if (! origImp) {
        return NULL;
    }
    
    class_replaceMethod(cls, selector, newImplementation, method_getTypeEncoding(method));
    return origImp;
}
