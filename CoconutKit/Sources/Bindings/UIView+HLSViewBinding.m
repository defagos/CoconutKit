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

- (void)updateBoundViewHierarchyAnimated:(NSNumber *)animated inViewController:(UIViewController *)viewController;
- (BOOL)checkBoundViewHierarchyInViewController:(UIViewController *)viewController withError:(NSError *__autoreleasing *)pError;

@end

@implementation UIView (HLSViewBinding)

#pragma mark Class methods

+ (void)load
{
    s_UIView__didMoveToWindow_Imp = (__typeof(s_UIView__didMoveToWindow_Imp))hls_class_swizzleSelector(self,
                                                                                                       @selector(didMoveToWindow),
                                                                                                       (IMP)swizzled_UIView__didMoveToWindow_Imp);
}

+ (void)showBindingsDebugOverlay
{
    [HLSViewBindingDebugOverlayViewController show];
}

#pragma mark Accessors and mutators

- (BOOL)isBindUpdateAnimated
{
    return [hls_getAssociatedObject(self, s_bindUpdateAnimatedKey) boolValue];
}

- (void)setBindUpdateAnimated:(BOOL)bindUpdateAnimated
{
    hls_setAssociatedObject(self, s_bindUpdateAnimatedKey, @(bindUpdateAnimated), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isBindInputChecked
{
    return [hls_getAssociatedObject(self, s_bindInputCheckedKey) boolValue];
}

- (void)setBindInputChecked:(BOOL)bindInputChecked
{
    hls_setAssociatedObject(self, s_bindInputCheckedKey, @(bindInputChecked), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isBindingSupported
{
    return [self respondsToSelector:@selector(updateViewWithValue:animated:)];
}

#pragma mark Bindings

- (void)updateBoundViewHierarchyAnimated:(BOOL)animated
{
    [self updateBoundViewHierarchyAnimated:@(animated) inViewController:[self nearestViewController]];
}

- (void)updateBoundViewHierarchy
{
    [self updateBoundViewHierarchyAnimated:nil inViewController:[self nearestViewController]];
}

- (BOOL)checkBoundViewHierarchyWithError:(NSError *__autoreleasing *)pError
{
    return [self checkBoundViewHierarchyInViewController:[self nearestViewController] withError:pError];
}

@end

@implementation UIView (HLSViewBindingPrivate)

#pragma mark Accessors and mutators

- (NSString *)bindKeyPath
{
    return hls_getAssociatedObject(self, s_bindKeyPath);
}

- (void)setBindKeyPath:(NSString *)bindKeyPath
{
    hls_setAssociatedObject(self, s_bindKeyPath, bindKeyPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)bindTransformer
{
    return hls_getAssociatedObject(self, s_bindTransformerKey);
}

- (void)setBindTransformer:(NSString *)bindTransformer
{
    hls_setAssociatedObject(self, s_bindTransformerKey, bindTransformer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (HLSViewBindingInformation *)bindingInformation
{
    return hls_getAssociatedObject(self, s_bindingInformationKey);
}

- (void)setBindingInformation:(HLSViewBindingInformation *)bindingInformation
{
    hls_setAssociatedObject(self, s_bindingInformationKey, bindingInformation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark Bindings

// Animated is a boolean. If nil, then use the behavior defined by the view (bindUpdateAnimated), otherwise
// override it
- (void)updateBoundViewHierarchyAnimated:(NSNumber *)animated inViewController:(UIViewController *)viewController
{
    // Stop at view controller boundaries. The following also correctly deals with viewController = nil
    UIViewController *nearestViewController = self.nearestViewController;
    if (nearestViewController && nearestViewController != viewController) {
        return;
    }
    
    if (animated) {
        [self updateBoundViewAnimated:[animated boolValue]];
    }
    else {
        [self updateBoundView];
    }
    
    for (UIView *subview in self.subviews) {
        [subview updateBoundViewHierarchyAnimated:animated inViewController:viewController];
    }
}

- (void)updateBoundViewAnimated:(BOOL)animated
{
    if (! self.bindingInformation) {
        return;
    }
    
    [self.bindingInformation updateViewAnimated:animated];
}

- (void)updateBoundView
{
    [self updateBoundViewAnimated:self.bindUpdateAnimated];
}

- (BOOL)checkBoundViewHierarchyInViewController:(UIViewController *)viewController withError:(NSError *__autoreleasing *)pError
{
    // Stop at view controller boundaries. The following also correctly deals with viewController = nil
    UIViewController *nearestViewController = self.nearestViewController;
    if (nearestViewController && nearestViewController != viewController) {
        return YES;
    }
    
    BOOL success = YES;
    if (self.bindingInformation) {
        NSError *error = nil;
        if (! [self.bindingInformation check:YES update:NO withError:&error]) {
            success = NO;
            [NSError combineError:error withError:pError];
        }
    }
    
    for (UIView *subview in self.subviews) {
        if (! [subview checkBoundViewHierarchyInViewController:viewController withError:pError]) {
            success = NO;
        }
    }
    
    return success;
}

@end

@implementation UIView (HLSViewBindingUpdateImplementation)

- (BOOL)check:(BOOL)check update:(BOOL)update withInputValue:(id)inputValue error:(NSError *__autoreleasing *)pError
{
    if (! self.bindingInformation) {
        return YES;
    }
    
    // The check parameter can be used to override the default behavior
    return [self.bindingInformation check:check && self.bindInputChecked update:update withInputValue:inputValue error:pError];
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
        [self updateBoundViewAnimated:self.bindUpdateAnimated];
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
            [self updateBoundViewAnimated:NO];
        }
    }
}
