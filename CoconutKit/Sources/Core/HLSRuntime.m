//
//  HLSRuntime.m
//  CoconutKit
//
//  Created by Samuel Défago on 30.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSRuntime.h"

IMP HLSSwizzleSelector(Class class, SEL origSel, SEL newSel)
{
    // Get the original implementation we are replacing
    IMP origImp = method_getImplementation(class_getInstanceMethod(class, origSel));
    
    Method newMethod = class_getInstanceMethod(class, newSel);
    class_replaceMethod(class, origSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    
    return origImp;
}

