//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIViewController+HLSInstantiation.h"

#import <objc/runtime.h>

@implementation UIViewController (HLSInstantiation)

#pragma mark Instantiation

- (instancetype)instanceWithStoryboardName:(NSString *)storyboardName inBundle:(NSBundle *)bundle
{
    if (! bundle) {
        bundle = [NSBundle mainBundle];
    }
    
    return [self viewControllerFromStoryboardWithName:storyboardName inBundle:bundle];
}

- (instancetype)instanceInBundle:(NSBundle *)bundle
{
    if (! bundle) {
        bundle = [NSBundle mainBundle];
    }
    
    UIViewController *viewController = [self viewControllerFromStoryboardWithName:nil inBundle:bundle];
    if (viewController) {
        return viewController;
    }
    
    NSString *nibName = [self nibNameInBundle:bundle];
    return [self initWithNibName:nibName bundle:bundle];
}

#pragma mark Resource lookup

- (NSString *)nibNameInBundle:(NSBundle *)bundle
{
    NSParameterAssert(bundle);
    
    Class class = [self class];
    while (class != Nil) {
        NSString *className = NSStringFromClass(class);
        if ([bundle pathForResource:className ofType:@"nib"]) {
            return className;
        }
        class = class_getSuperclass(class);
    }
    return nil;
}

- (UIViewController *)viewControllerFromStoryboardWithName:(NSString *)storyboardName inBundle:(NSBundle *)bundle
{
    NSParameterAssert(bundle);
    
    Class class = [self class];
    while (class != Nil) {
        NSString *storyboardLookupName = storyboardName ?: NSStringFromClass(class);
        UIViewController *viewController = [UIViewController viewControllerFromStoryboardWithName:storyboardLookupName class:class inBundle:bundle];
        if (viewController) {
            return viewController;
        }
        class = class_getSuperclass(class);
    }
    return nil;
}

+ (UIViewController *)viewControllerFromStoryboardWithName:(NSString *)storyboardName class:(Class)class inBundle:(NSBundle *)bundle
{
    NSParameterAssert(storyboardName);
    NSParameterAssert(class);
    NSParameterAssert(bundle);
    
    NSString *identifier = NSStringFromClass(class);
    if (! [bundle pathForResource:identifier ofType:@"storyboardc"]) {
        return nil;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:identifier bundle:bundle];
    
    // Throws an exception if no view controller is found for the specified identifier
    UIViewController *viewController = nil;
    @try {
        viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    }
    @catch (NSException *exception) {}
    
    if (viewController) {
        return viewController;
    }
    
    viewController = [storyboard instantiateInitialViewController];
    if (! [viewController isKindOfClass:class]) {
        return nil;
    }
    
    return viewController;
}

@end
