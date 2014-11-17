//
//  UIView+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "UIView+HLSViewBinding.h"

#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "HLSViewBindingDebugOverlayViewController.h"
#import "HLSViewBindingInformation.h"
#import "UIView+HLSViewBindingImplementation.h"
#import "NSError+HLSExtensions.h"
#import "UIView+HLSExtensions.h"

// Keys for associated objects
static void *s_bindKeyPath = &s_bindKeyPath;
static void *s_bindTransformerKey = &s_bindTransformerKey;
static void *s_bindUpdateAnimatedKey = &s_bindUpdateAnimatedKey;
static void *s_bindInputCheckedKey = &s_bindInputCheckedKey;
static void *s_bindingInformationKey = &s_bindingInformationKey;

// Original implementation of the methods we swizzle
static void (*s_UIView__didMoveToWindow_Imp)(id, SEL) = NULL;

// Swizzled method implementations
static void swizzled_UIView__didMoveToWindow_Imp(UIView *self, SEL _cmd);

@interface UIView (HLSViewBindingPrivate)

@property (nonatomic, strong) NSString *bindKeyPath;
@property (nonatomic, strong) NSString *bindTransformer;

@property (nonatomic, strong) HLSViewBindingInformation *bindingInformation;

- (void)refreshBindingsInViewController:(UIViewController *)viewController;
- (BOOL)checkInputValuesInViewController:(UIViewController *)viewController withError:(NSError *__autoreleasing *)pError;
- (BOOL)updateModelInViewController:(UIViewController *)viewController withError:(NSError *__autoreleasing *)pError;
- (BOOL)checkAndUpdateModelWithInputValuesInViewController:(UIViewController *)viewController error:(NSError *__autoreleasing *)pError;

@end

@implementation UIView (HLSViewBinding)

#pragma mark Class methods

+ (void)load
{
    s_UIView__didMoveToWindow_Imp = (void (*)(id, SEL))hls_class_swizzleSelector(self,
                                                                                 @selector(didMoveToWindow),
                                                                                 (IMP)swizzled_UIView__didMoveToWindow_Imp);
}

+ (void)debugBindings
{
    [HLSViewBindingDebugOverlayViewController show];
}

#pragma mark Accessors and mutators

- (BOOL)isBindUpdateAnimated
{
    return [objc_getAssociatedObject(self, s_bindUpdateAnimatedKey) boolValue];
}

- (void)setBindUpdateAnimated:(BOOL)bindUpdateAnimated
{
    objc_setAssociatedObject(self, s_bindUpdateAnimatedKey, @(bindUpdateAnimated), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isBindInputChecked
{
    return [objc_getAssociatedObject(self, s_bindInputCheckedKey) boolValue];
}

- (void)setBindInputChecked:(BOOL)bindInputChecked
{
    objc_setAssociatedObject(self, s_bindInputCheckedKey, @(bindInputChecked), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isBindingSupported
{
    return [self respondsToSelector:@selector(updateViewWithValue:animated:)];
}

#pragma mark Bindings

- (void)refreshBindings
{
    [self refreshBindingsInViewController:[self nearestViewController]];
}

- (BOOL)checkInputValuesWithError:(NSError *__autoreleasing *)pError
{
    return [self checkInputValuesInViewController:[self nearestViewController] withError:pError];
}

- (BOOL)updateModelWithError:(NSError *__autoreleasing *)pError
{
    return [self updateModelInViewController:[self nearestViewController] withError:pError];
}

- (BOOL)checkAndUpdateModelWithInputValuesError:(NSError *__autoreleasing *)pError
{
    return [self checkAndUpdateModelWithInputValuesInViewController:[self nearestViewController] error:pError];
}

@end

@implementation UIView (HLSViewBindingPrivate)

#pragma mark Accessors and mutators

- (NSString *)bindKeyPath
{
    return objc_getAssociatedObject(self, s_bindKeyPath);
}

- (void)setBindKeyPath:(NSString *)bindKeyPath
{
    objc_setAssociatedObject(self, s_bindKeyPath, bindKeyPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)bindTransformer
{
    return objc_getAssociatedObject(self, s_bindTransformerKey);
}

- (void)setBindTransformer:(NSString *)bindTransformer
{
    objc_setAssociatedObject(self, s_bindTransformerKey, bindTransformer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (HLSViewBindingInformation *)bindingInformation
{
    return objc_getAssociatedObject(self, s_bindingInformationKey);
}

- (void)setBindingInformation:(HLSViewBindingInformation *)bindingInformation
{
    objc_setAssociatedObject(self, s_bindingInformationKey, bindingInformation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark Bindings

- (void)refreshBindingsInViewController:(UIViewController *)viewController
{
    // Stop at view controller boundaries. The following also correctly deals with viewController = nil
    UIViewController *nearestViewController = self.nearestViewController;
    if (nearestViewController && nearestViewController != viewController) {
        return;
    }
    
    [self updateViewAnimated:YES];
    
    for (UIView *subview in self.subviews) {
        [subview refreshBindingsInViewController:viewController];
    }
}

- (void)updateView
{
    [self updateViewAnimated:self.bindUpdateAnimated];
}

- (void)updateViewAnimated:(BOOL)animated
{
    if (! self.bindingInformation) {
        return;
    }
    
    [self.bindingInformation updateViewAnimated:animated];
}

- (BOOL)checkInputValuesInViewController:(UIViewController *)viewController withError:(NSError *__autoreleasing *)pError
{
    // Stop at view controller boundaries. The following also correctly deals with viewController = nil
    UIViewController *nearestViewController = self.nearestViewController;
    if (nearestViewController && nearestViewController != viewController) {
        return YES;
    }
    
    BOOL success = YES;
    if (self.bindingInformation) {
        NSError *error = nil;
        if (! [self.bindingInformation checkInputValueWithError:&error]) {
            success = NO;
            [NSError combineError:error withError:pError];
        }
    }
    
    for (UIView *subview in self.subviews) {
        if (! [subview checkInputValuesInViewController:viewController withError:pError]) {
            success = NO;
        }
    }
    
    return success;
}

- (BOOL)updateModelInViewController:(UIViewController *)viewController withError:(NSError *__autoreleasing *)pError
{
    // Stop at view controller boundaries. The following also correctly deals with viewController = nil
    UIViewController *nearestViewController = self.nearestViewController;
    if (nearestViewController && nearestViewController != viewController) {
        return YES;
    }
    
    BOOL success = YES;
    if (self.bindingInformation) {
        NSError *error = nil;
        if (! [self.bindingInformation updateModelWithInputValueError:&error]) {
            success = NO;
            [NSError combineError:error withError:pError];
        }
    }
    
    for (UIView *subview in self.subviews) {
        if (! [subview updateModelInViewController:viewController withError:pError]) {
            success = NO;
        }
    }
    
    return success;
}

- (BOOL)checkAndUpdateModelWithInputValuesInViewController:(UIViewController *)viewController error:(NSError *__autoreleasing *)pError
{
    // Stop at view controller boundaries. The following also correctly deals with viewController = nil
    UIViewController *nearestViewController = self.nearestViewController;
    if (nearestViewController && nearestViewController != viewController) {
        return YES;
    }
    
    BOOL success = YES;
    if (self.bindingInformation) {
        NSError *checkError = nil;
        if (! [self.bindingInformation checkInputValueWithError:&checkError]) {
            success = NO;
            [NSError combineError:checkError withError:pError];
        }
        
        NSError *updateError = nil;
        if (! [self.bindingInformation updateModelWithInputValueError:&updateError]) {
            success = NO;
            [NSError combineError:updateError withError:pError];
        }
    }
    
    for (UIView *subview in self.subviews) {
        if (! [subview updateModelInViewController:viewController withError:pError]) {
            success = NO;
        }
    }
    
    return success;
}

@end

@implementation UIView (HLSViewBindingUpdateImplementation)

- (BOOL)checkInputValue:(id)inputValue withError:(NSError *__autoreleasing *)pError
{
    if (! self.bindingInformation || ! self.bindInputChecked) {
        return YES;
    }
    
    return [self.bindingInformation checkInputValue:inputValue withError:pError];
}

- (BOOL)updateModelWithInputValue:(id)inputValue error:(NSError *__autoreleasing *)pError
{
    if (! self.bindingInformation) {
        return YES;
    }
    
    return [self.bindingInformation updateModelWithInputValue:inputValue error:pError];
}

- (BOOL)checkAndUpdateModelWithInputValue:(id)inputValue error:(NSError *__autoreleasing *)pError
{
    if (! self.bindingInformation) {
        return YES;
    }
    
    if (self.bindInputChecked) {
        return [self.bindingInformation checkAndUpdateModelWithInputValue:inputValue error:pError];
    }
    else {
        return [self.bindingInformation updateModelWithInputValue:inputValue error:pError];
    }
}

@end

@implementation UIView (HLSViewBindingProgrammatic)

- (void)bindToKeyPath:(NSString *)keyPath withTransformer:(NSString *)transformer
{
    self.bindKeyPath = keyPath;
    self.bindTransformer = transformer;
    
    self.bindingInformation = [[HLSViewBindingInformation alloc] initWithKeyPath:keyPath
                                                                 transformerName:transformer
                                                                            view:self];
    
    // If the view is displayed, update it
    if (self.window) {
        [self updateViewAnimated:self.bindUpdateAnimated];
    }
}

@end

#pragma mark Swizzled method implementations

// By swizzling -didMoveToWindow, we know that the view has been added to its view hierarchy. The responder chain is therefore
// complete
static void swizzled_UIView__didMoveToWindow_Imp(UIView *self, SEL _cmd)
{
    (*s_UIView__didMoveToWindow_Imp)(self, _cmd);
    
    if (self.window) {
        if (self.bindKeyPath) {
            if (! self.bindingInformation) {
                self.bindingInformation = [[HLSViewBindingInformation alloc] initWithKeyPath:self.bindKeyPath
                                                                             transformerName:self.bindTransformer
                                                                                        view:self];
            }
            [self updateViewAnimated:NO];
        }
    }
}
