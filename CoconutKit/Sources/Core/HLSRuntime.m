//
//  HLSRuntime.m
//  CoconutKit
//
//  Created by Samuel Défago on 30.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSRuntime.h"

IMP HLSSwizzleClassSelector(Class clazz, SEL selector, IMP newImplementation)
{
    // Get the original implementation we are replacing
    Class metaClass = objc_getMetaClass(class_getName(clazz));
    Method method = class_getClassMethod(metaClass, selector);
    IMP origImp = method_getImplementation(method);
    if (! origImp) {
        return NULL;
    }
    
    class_replaceMethod(metaClass, selector, newImplementation, method_getTypeEncoding(method));
    return origImp;
}

IMP HLSSwizzleSelector(Class clazz, SEL selector, IMP newImplementation)
{
    // Get the original implementation we are replacing
    Method method = class_getInstanceMethod(clazz, selector);
    IMP origImp = method_getImplementation(method);
    if (! origImp) {
        return NULL;
    }
    
    class_replaceMethod(clazz, selector, newImplementation, method_getTypeEncoding(method));
    return origImp;
}
