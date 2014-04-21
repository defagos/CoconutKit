//
//  UIView+HLSViewBinding.m
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "UIView+HLSViewBinding.h"

#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "HLSViewBindingInformation.h"
#import "NSError+HLSExtensions.h"
#import "UIView+HLSExtensions.h"
#import "UIViewController+HLSViewBindingFriend.h"

// Keys for associated objects
static void *s_bindKeyPath = &s_bindKeyPath;
static void *s_bindTransformerKey = &s_bindTransformerKey;
static void *s_updatingModelAutomaticallyKey = &s_updatingModelAutomaticallyKey;
static void *s_checkingDisplayedValueAutomaticallyKey = &s_checkingDisplayedValueAutomaticallyKey;
static void *s_boundObjectKey = &s_boundObjectKey;
static void *s_bindingInformationKey = &s_bindingInformationKey;

// Original implementation of the methods we swizzle
static void (*s_UIView__didMoveToWindow_Imp)(id, SEL) = NULL;

// Swizzled method implementations
static void swizzled_UIView__didMoveToWindow_Imp(UIView *self, SEL _cmd);

@interface UIView (HLSViewBindingPrivate)

/**
 * Private properties which must be set via user-defined runtime attributes
 */
@property (nonatomic, strong) NSString *bindKeyPath;
@property (nonatomic, strong) NSString *bindTransformer;

@property (nonatomic, strong) id boundObject;
@property (nonatomic, strong) HLSViewBindingInformation *bindingInformation;

- (void)bindToObject:(id)object inViewController:(UIViewController *)viewController recursive:(BOOL)recursive;
- (void)refreshBindingsInViewController:(UIViewController *)viewController recursive:(BOOL)recursive forced:(BOOL)forced;
- (BOOL)bindsRecursively;
- (BOOL)checkDisplayedValuesInViewController:(UIViewController *)viewController exhaustive:(BOOL)exhaustive withError:(NSError **)pError;
- (BOOL)updateModelInViewController:(UIViewController *)viewController withError:(NSError **)pError;

@end

@implementation UIView (HLSViewBinding)

#pragma mark Class methods

+ (void)load
{
    s_UIView__didMoveToWindow_Imp = (void (*)(id, SEL))hls_class_swizzleSelector(self,
                                                                                 @selector(didMoveToWindow),
                                                                                 (IMP)swizzled_UIView__didMoveToWindow_Imp);
}

#pragma mark Accessors and mutators

- (BOOL)isUpdatingModelAutomatically
{
    return [objc_getAssociatedObject(self, s_updatingModelAutomaticallyKey) boolValue];
}

- (void)setUpdatingModelAutomatically:(BOOL)updatingModelAutomatically
{
    objc_setAssociatedObject(self, s_updatingModelAutomaticallyKey, @(updatingModelAutomatically), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isCheckingDisplayedValueAutomatically
{
    return [objc_getAssociatedObject(self, s_checkingDisplayedValueAutomaticallyKey) boolValue];
}

- (void)setCheckingDisplayedValueAutomatically:(BOOL)checkingDisplayedValueAutomatically
{
    objc_setAssociatedObject(self, s_checkingDisplayedValueAutomaticallyKey, @(checkingDisplayedValueAutomatically), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark Bindings

- (void)bindToObject:(id)object
{
    [self bindToObject:object inViewController:[self nearestViewController] recursive:[self bindsRecursively]];
}

- (void)refreshBindingsForced:(BOOL)forced
{
    [self refreshBindingsInViewController:[self nearestViewController] recursive:[self bindsRecursively] forced:forced];
}

- (BOOL)checkDisplayedValuesExhaustive:(BOOL)exhaustive withError:(NSError **)pError
{
    return [self checkDisplayedValuesInViewController:[self nearestViewController] exhaustive:exhaustive withError:pError];
}

- (BOOL)updateModelWithError:(NSError **)pError
{
    return [self updateModelInViewController:[self nearestViewController] withError:pError];
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

- (id)boundObject
{
    return objc_getAssociatedObject(self, s_boundObjectKey);
}

- (void)setBoundObject:(id)boundObject
{
    objc_setAssociatedObject(self, s_boundObjectKey, boundObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

// Bind to an object in the context of a view controller (might be nil). Stops at view controller boundaries. Correctly
// deals with viewController = nil as well
- (void)bindToObject:(id)object inViewController:(UIViewController *)viewController recursive:(BOOL)recursive
{   
    // Stop at view controller boundaries (correctly deals with viewController = nil)
    UIViewController *nearestViewController = self.nearestViewController;
    if (nearestViewController && nearestViewController != viewController) {
        return;
    }
    
    // Retain the object, so that view hierarchies can be bound to locally created objects assigned to them
    self.boundObject = object;
    
    if (self.bindKeyPath) {
        if ([self respondsToSelector:@selector(updateViewWithValue:)]) {
            HLSLoggerDebug(@"Bind object %@ to view %@ with keyPath %@", object, self, self.bindKeyPath);
            
            self.bindingInformation = [[HLSViewBindingInformation alloc] initWithObject:object
                                                                                keyPath:self.bindKeyPath
                                                                        transformerName:self.bindTransformer
                                                                                   view:self];
            [self updateViewValue];
        }
        else {
            HLSLoggerWarn(@"A binding key path has been set for %@, but its class does not implement bindings", self);
        }
    }
    
    if (recursive) {
        for (UIView *subview in self.subviews) {
            [subview bindToObject:object inViewController:viewController recursive:recursive];
        }
    }
}

- (void)refreshBindingsInViewController:(UIViewController *)viewController recursive:(BOOL)recursive forced:(BOOL)forced
{
    // Stop at view controller boundaries. The following also correctly deals with viewController = nil
    UIViewController *nearestViewController = self.nearestViewController;
    if (nearestViewController && nearestViewController != viewController) {
        return;
    }
    
    if (forced) {
        // Not recursive here. Recursion is made below
        [self bindToObject:self.boundObject inViewController:viewController recursive:NO];
    }
    else {
        [self updateViewValue];
    }
    
    if (recursive) {
        for (UIView *subview in self.subviews) {
            [subview refreshBindingsInViewController:viewController recursive:recursive forced:forced];
        }
    }
}

- (BOOL)bindsRecursively
{
    if ([self respondsToSelector:@selector(bindsSubviewsRecursively)]) {
        return [self performSelector:@selector(bindsSubviewsRecursively)];
    }
    else {
        return YES;
    }
}

- (void)updateViewValue
{
    if (! self.bindingInformation) {
        return;
    }
    
    NSAssert([self respondsToSelector:@selector(updateViewWithValue:)], @"Binding could only be made it -updateWithValue: is implemented");
    
    id value = [self.bindingInformation value];
    [self performSelector:@selector(updateViewWithValue:) withObject:value];
}

- (BOOL)checkDisplayedValuesInViewController:(UIViewController *)viewController exhaustive:(BOOL)exhaustive withError:(NSError **)pError
{
    // Stop at view controller boundaries. The following also correctly deals with viewController = nil
    UIViewController *nearestViewController = self.nearestViewController;
    if (nearestViewController && nearestViewController != viewController) {
        return YES;
    }
    
    BOOL success = YES;
    if ([self respondsToSelector:@selector(displayedValue)]) {
        id displayedValue = [self performSelector:@selector(displayedValue)];
        
        NSError *error = nil;
        if (! [self checkDisplayedValue:displayedValue withError:&error]) {
            if (! exhaustive) {
                if (pError) {
                    *pError = error;
                }
                return NO;
            }
            
            success = NO;
            
            if (pError) {
                if (*pError) {
                    [*pError addObject:error forKey:HLSDetailedErrorsKey];
                }
                else {
                    *pError = [NSError errorWithDomain:CoconutKitErrorDomain
                                                  code:HLSErrorValidationMultipleErrors];
                }
            }
        }
    }
    
    for (UIView *subview in self.subviews) {
        if (! [subview checkDisplayedValuesInViewController:viewController exhaustive:exhaustive withError:pError]) {
            if (! exhaustive) {
                return NO;
            }
            
            success = NO;
        }
    }
    
    return success;
}

- (BOOL)updateModelInViewController:(UIViewController *)viewController withError:(NSError **)pError
{
    // Stop at view controller boundaries. The following also correctly deals with viewController = nil
    UIViewController *nearestViewController = self.nearestViewController;
    if (nearestViewController && nearestViewController != viewController) {
        return YES;
    }
    
    BOOL success = YES;
    if ([self respondsToSelector:@selector(displayedValue)]) {
        id displayedValue = [self performSelector:@selector(displayedValue)];
        
        NSError *error = nil;
        if (! [self updateModelWithDisplayedValue:displayedValue error:&error]) {
            if (pError) {
                if (*pError) {
                    [*pError addObject:error forKey:HLSDetailedErrorsKey];
                }
                else {
                    *pError = [NSError errorWithDomain:CoconutKitErrorDomain
                                                  code:HLSErrorValidationMultipleErrors];
                }
            }
            
            success = NO;
        }
    }
    
    for (UIView *subview in self.subviews) {
        if (! [subview updateModelInViewController:viewController withError:pError]) {
            success = NO;
        }
    }
    
    return success;
}

- (BOOL)checkDisplayedValue:(id)displayedValue withError:(NSError **)pError
{
    if (! self.bindingInformation) {
        // No binding, nothing to do
        return YES;
    }
    
    id value = nil;
    if (! [self.bindingInformation convertTransformedValue:displayedValue toValue:&value withError:pError]) {
        return NO;
    }
    
    if (! [self.bindingInformation checkValue:value withError:pError]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)updateModelWithDisplayedValue:(id)displayedValue error:(NSError **)pError
{
    if (! self.bindingInformation) {
        // No binding, nothing to do
        return YES;
    }
    
    id value = nil;
    if (! [self.bindingInformation convertTransformedValue:displayedValue toValue:&value withError:pError]) {
        return NO;
    }
    
    if (! [self.bindingInformation updateWithValue:value error:pError]) {
        return NO;
    }
    
    return YES;
}

@end

@implementation UIView (HLSViewBindingUpdateImplementation)

- (BOOL)checkAndUpdateModelWithDisplayedValue:(id)displayedValue error:(NSError **)pError
{
    if (! self.bindingInformation) {
        // No binding, nothing to do
        return YES;
    }
    
    id value = nil;
    if (! [self.bindingInformation convertTransformedValue:displayedValue toValue:&value withError:pError]) {
        return NO;
    }
    
    BOOL success = YES;
    if (self.checkingDisplayedValueAutomatically) {
        if (! [self.bindingInformation checkValue:value withError:pError]) {
            success = NO;
        }
    }
    
    if (self.updatingModelAutomatically) {
        if (! [self.bindingInformation updateWithValue:value error:pError]) {
            success = NO;
        }
    }
    
    return success;
}

@end

#pragma mark Swizzled method implementations

// By swizzling -didMoveToWindow, we know that the view has been added to its view hierarchy. The responder chain is therefore
// complete
static void swizzled_UIView__didMoveToWindow_Imp(UIView *self, SEL _cmd)
{
    (*s_UIView__didMoveToWindow_Imp)(self, _cmd);
    
    // This method is called every time the view has been added to a view hierarchy. When a view gets added to a view hierarchy, it gets
    // called once with self.window != nil. When removing a view from its hierarchy, it gets called once with self.window == nil. When
    // transferring a view between two view hierarchies, it gets called twice (once with self.window == nil for removal from the old
    // hierarchy, and once with self.window != nil for the new view hierarchy)
    //
    // We can choose between two different strategies:
    //
    // 1) When the window changes (to != nil), invalidate the cached binding information. The binding context might namely change during
    //    the process of transferring the view to a new hierarchy. More often than not, and though this is the most correct approach, this
    //    might lead to unnecessary binding calculation (views can namely be transferred between view hierarchies without visible consequences,
    //    and calculating the binding information in such cases usually lead to the same result).
    //
    //    The corresponding code would be:
    //
    //    if (self.window) {
    //        if (self.bindKeyPath && ! self.bindingInformation) {
    //            UIViewController *nearestViewController = self.nearestViewController;
    //            id boundObject = self.boundObject ?: nearestViewController.boundObject;
    //            [self bindToObject:boundObject inViewController:nearestViewController recursive:NO];
    //        }
    //        else if (self.bindingInformation) {
    //            [self updateViewValue];
    //        }
    //    }
    //    else {
    //        self.bindingInformation = nil;
    //    }
    //
    // 2) When the window changes (to != nil), we do not recalculate verified binding information. This does not automatically take into
    //    account transfers between view hierarchies, but avoids useless binding recalculations (in general, we only want to verify binding
    //    information once). If recalculation is really needed, the -refreshBindingsForced: method can still be called. This is the approach
    //    which has been retained here
    
    if (self.window) {
        if (self.bindKeyPath && ! self.bindingInformation) {
            UIViewController *nearestViewController = self.nearestViewController;
            id boundObject = self.boundObject ?: nearestViewController.boundObject;
            [self bindToObject:boundObject inViewController:nearestViewController recursive:NO];
        }
        // Do not recalculate valid binding information, even if the window has changed
        else if (self.bindingInformation && ! self.bindingInformation.verified) {
            [self updateViewValue];
        }        
    }
}
