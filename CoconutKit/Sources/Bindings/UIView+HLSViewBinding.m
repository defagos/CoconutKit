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
#import "UIView+HLSExtensions.h"
#import "UIViewController+HLSViewBindingFriend.h"

// TODO:
//  - bound table view (use restricted interface proxy to restrict interface. Implement delegate
//    to which delegate forwards events; implement a runtime function to check whether a method
//    belongs to a protocol, and use it as a criterium to know whether the delegate must forward
//    unrecognized selectors to the bound table view delegate)
//  - demo with table view
//  - demo with embedded view controller (via placeholder view controller) to test boundaries
//  - document: Bindings stop at VC boundaries, and formatter selector resolving as well. A view controller (when
//    available) namely defines a binding context

// Keys for associated objects
static void *s_bindKeyPath = &s_bindKeyPath;
static void *s_bindFormatterKey = &s_bindFormatterKey;
static void *s_boundObjectKey = &s_boundObjectKey;
static void *s_bindingInformationKey = &s_bindingInformationKey;

// Original implementation of the methods we swizzle
static void (*s_UIView__awakeFromNib_Imp)(id, SEL) = NULL;

// Swizzled method implementations
static void swizzled_UIView__awakeFromNib_Imp(UIView *self, SEL _cmd);

@interface UIView (HLSViewBindingPrivate)

/**
 * Private properties which must be set via user-defined runtime attributes
 */
@property (nonatomic, strong) NSString *bindKeyPath;
@property (nonatomic, strong) NSString *bindFormatter;

@property (nonatomic, strong) id boundObject;
@property (nonatomic, strong) HLSViewBindingInformation *bindingInformation;

- (void)bindToObject:(id)object inViewController:(UIViewController *)viewController recursive:(BOOL)recursive;
- (void)refreshBindingsInViewController:(UIViewController *)viewController recursive:(BOOL)recursive;
- (BOOL)bindsRecursively;

@end

@implementation UIView (HLSViewBinding)

#pragma mark Class methods

+ (void)load
{
    s_UIView__awakeFromNib_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self,
                                                                       @selector(awakeFromNib),
                                                                       (IMP)swizzled_UIView__awakeFromNib_Imp);
}

#pragma mark Bindings

- (void)bindToObject:(id)object
{
    if (! object) {
        HLSLoggerError(@"An object must be provided");
        return;
    }
    
    [self bindToObject:object inViewController:[self nearestViewController] recursive:[self bindsRecursively]];
}

- (void)refreshBindings
{
    [self refreshBindingsInViewController:[self nearestViewController] recursive:[self bindsRecursively]];
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

- (NSString *)bindFormatter
{
    return objc_getAssociatedObject(self, s_bindFormatterKey);
}

- (void)setBindFormatter:(NSString *)bindFormatter
{
    objc_setAssociatedObject(self, s_bindFormatterKey, bindFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

// Bind to an object in the context of a view controller (might be nil). Stops at view controller boundaries
- (void)bindToObject:(id)object inViewController:(UIViewController *)viewController recursive:(BOOL)recursive
{   
    // Stop at view controller boundaries. The following also correctly deals with viewController = nil
    UIViewController *nearestViewController = self.nearestViewController;
    if (nearestViewController && nearestViewController != viewController) {
        return;
    }
    
    self.boundObject = object;
    
    if (self.bindKeyPath) {
        if ([self respondsToSelector:@selector(updateViewWithText:)]) {
            HLSLoggerDebug(@"Bind object %@ to view %@ with keyPath %@", object, self, self.bindKeyPath);
            
            self.bindingInformation = [[HLSViewBindingInformation alloc] initWithObject:object
                                                                                keyPath:self.bindKeyPath
                                                                          formatterName:self.bindFormatter
                                                                                   view:self];
            [self updateText];
        }
        else {
            HLSLoggerWarn(@"A binding path has been set for %@, but its class does not implement bindings", self);
        }
    }
    
    if (recursive) {
        for (UIView *subview in self.subviews) {
            [subview bindToObject:object inViewController:viewController recursive:recursive];
        }
    }
}

- (void)refreshBindingsInViewController:(UIViewController *)viewController recursive:(BOOL)recursive
{
    // Stop at view controller boundaries. The following also correctly deals with viewController = nil
    UIViewController *nearestViewController = self.nearestViewController;
    if (nearestViewController && nearestViewController != viewController) {
        return;
    }
    
    [self updateText];
    
    if (recursive) {
        for (UIView *subview in self.subviews) {
            [subview refreshBindingsInViewController:viewController recursive:recursive];
        }
    }
}

- (BOOL)bindsRecursively
{
    if ([self respondsToSelector:@selector(updatesSubviewsRecursively)]) {
        return [self updatesSubviewsRecursively];
    }
    else {
        return YES;
    }
}

- (void)updateText
{
    if (! self.bindingInformation) {
        // If an invalid keypath has been set and bindings are supported, then set the text to nil
        if (self.bindKeyPath && [self respondsToSelector:@selector(updateViewWithText:)]) {
            [self updateViewWithText:nil];
        }
        return;
    }
    
    NSString *text = [self.bindingInformation text];
    [self updateViewWithText:text];
}

@end

#pragma mark Swizzled method implementations

static void swizzled_UIView__awakeFromNib_Imp(UIView *self, SEL _cmd)
{
    (*s_UIView__awakeFromNib_Imp)(self, _cmd);
    
    if (self.bindKeyPath && ! self.bindingInformation) {
        UIViewController *nearestViewController = self.nearestViewController;
        id boundObject = self.boundObject ?: nearestViewController.boundObject;
        [self bindToObject:boundObject inViewController:nearestViewController recursive:NO];
    }
}
