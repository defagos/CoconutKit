//
//  HLSRuntime.m
//  CoconutKit
//
//  Created by Samuel Défago on 30.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSRuntime.h"

#import "stdlib.h"

Protocol * __unsafe_unretained *hls_class_copyProtocolList(Class cls, unsigned int *pCount)
{
    unsigned int numberOfProtocols = 0;
    Protocol **protocols = NULL;
    
    // class_copyProtocolList only returns the protocols which the current class conforms to (ignoring
    // superclasses). Climb up the hierarchy
    Class class = cls;
    while (class) {
        unsigned int numberOfClassProtocols = 0;
        Protocol **classProtocols = class_copyProtocolList(class, &numberOfClassProtocols);
        if (classProtocols) {
            // First class protocol list retrieved. Keep the allocated protocol array, do not free it
            if (numberOfProtocols == 0) {
                protocols = classProtocols;
            }
            // Protocols already available. Resize and append by copy
            else {
                protocols = realloc(protocols, (numberOfProtocols + numberOfClassProtocols) * sizeof(Protocol *));
                for (unsigned int i = 0; i < numberOfClassProtocols; ++i) {
                    protocols[numberOfProtocols + i] = classProtocols[i];
                }
                
                free(classProtocols);
            }
            
            numberOfProtocols += numberOfClassProtocols;    
        }
        
        class = class_getSuperclass(class);
    }
    
    if (pCount) {
        *pCount = numberOfProtocols;
    }
    return protocols;
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

BOOL hls_class_implementsProtocol(Class cls, Protocol *protocol)
{
    // Only interested in optional methods. Required methods are checked at compilation time
    unsigned int numberOfMethods = 0;
    
    // TODO: Methods in other protocols adopted by this protocol are probably not included. Verify and fix
    struct objc_method_description *methodDescriptions = protocol_copyMethodDescriptionList(protocol, 
                                                                                            NO /* looking at optional methods suffices */, 
                                                                                            YES, 
                                                                                            &numberOfMethods);
    for (unsigned int i = 0; i < numberOfMethods; ++i) {
        struct objc_method_description methodDescription = methodDescriptions[i];
        SEL selector = methodDescription.name;
        
        // This searches in superclasses as well
        if (! class_getInstanceMethod(cls, selector)) {
            return NO;
        }
    }
    
    return YES;
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
