//
//  HLSRuntime.m
//  CoconutKit
//
//  Created by Samuel Défago on 30.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSRuntime.h"

IMP HLSSwizzleClassSelectoR(Class clazz, SEL selector, IMP newImplementation)
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

IMP HLSSwizzleSelectoR(Class clazz, SEL selector, IMP newImplementation)
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

IMP HLSSwizzleClassSelector(Class class, SEL origSel, SEL newSel)
{
    Class metaClass = objc_getMetaClass(class_getName(class));
        
    // Get the original implementation we are replacing
    IMP origImp = method_getImplementation(class_getClassMethod(metaClass, origSel));
    if (! origImp) {
        return NULL;
    }
    
    Method newMethod = class_getClassMethod(metaClass, newSel);
    class_replaceMethod(metaClass, origSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    
    return origImp;
}

IMP HLSSwizzleSelector(Class clazz, SEL origSel, SEL newSel)
{
    // Get the original implementation we are replacing
    IMP origImp = method_getImplementation(class_getInstanceMethod(clazz, origSel));
    if (! origImp) {
        return NULL;
    }
    
    Method newMethod = class_getInstanceMethod(clazz, newSel);
    class_replaceMethod(clazz, origSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    
    return origImp;
}
