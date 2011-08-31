//
//  HLSRuntime.m
//  CoconutKit
//
//  Created by Samuel Défago on 30.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSRuntime.h"

IMP HLSSwizzleSelector(Class clazz, SEL origSel, SEL newSel)
{
    // Get the original implementation we are replacing
    IMP origImp = method_getImplementation(class_getInstanceMethod(clazz, origSel));
    
    Method newMethod = class_getInstanceMethod(clazz, newSel);
    class_replaceMethod(clazz, origSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    
    return origImp;
}

