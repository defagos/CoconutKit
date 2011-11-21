//
//  HLSRuntime.m
//  CoconutKit
//
//  Created by Samuel Défago on 30.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSRuntime.h"

IMP HLSSwizzleClassSelector(Class class, SEL origSel, SEL newSel)
{
    Class metaClass = objc_getMetaClass(class_getName(class));
        
    // Get the original implementation we are replacing
    IMP origImp = method_getImplementation(class_getClassMethod(metaClass, origSel));
    
    Method newMethod = class_getClassMethod(metaClass, newSel);
    IMP oldImp = class_replaceMethod(metaClass, 
                                     origSel, 
                                     method_getImplementation(newMethod), 
                                     method_getTypeEncoding(newMethod));
    NSCAssert(origImp == oldImp, @"Method not swizzled properly");
    oldImp = NULL;      // To remove unused variable warning when assertions have been disabled
    
    return origImp;
}

IMP HLSSwizzleSelector(Class class, SEL origSel, SEL newSel)
{
    // Get the original implementation we are replacing
    IMP origImp = method_getImplementation(class_getInstanceMethod(class, origSel));
    
    Method newMethod = class_getInstanceMethod(class, newSel);
    IMP oldImp = class_replaceMethod(class,
                                     origSel, 
                                     method_getImplementation(newMethod),
                                     method_getTypeEncoding(newMethod));
    NSCAssert(origImp == oldImp, @"Method not swizzled properly");
    oldImp = NULL;      // To remove unused variable warning when assertions have been disabled
    
    return origImp;
}

