//
//  UIView+HLSViewBinding.m
//  mBanking
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "UIView+HLSViewBinding.h"

#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "HLSViewObjectBindingContext.h"
#import "UIView+HLSExtensions2.h"

// TODO: Rename ViewBindings -> ViewBinding

// Keys for associated objects
static void *s_bindKeyPath = &s_bindKeyPath;
static void *s_bindFormatterKey = &s_bindFormatterKey;
static void *s_bindingContextKey = &s_bindingContextKey;

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

// Once we have found which object provides the value, store it for further efficient use
@property (nonatomic, strong) HLSViewObjectBindingContext *bindingContext;

@end

@implementation UIView (HLSViewBinding)

#pragma mark Class methods

+ (void)load
{
    s_UIView__awakeFromNib_Imp  = (void (*)(id, SEL))HLSSwizzleSelector(self,
                                                                        @selector(awakeFromNib),
                                                                        (IMP)swizzled_UIView__awakeFromNib_Imp);
}

#pragma mark Bindings

- (void)bindToObject:(id)object
{
    [self bindToObject:object inViewController:[self nearestViewController]];
}

- (void)bindToObject:(id)object inViewController:(UIViewController *)viewController
{
    if (! object) {
        HLSLoggerError(@"An object must be provided");
        return;
    }
    
    // Stop at view controller boundaries. Also work when viewController = nil
    if (self.viewController && self.viewController != viewController) {
        return;
    }
    
    if (self.bindKeyPath) {
        if ([self respondsToSelector:@selector(updateViewWithText:)]) {
            self.bindingContext = [[HLSViewObjectBindingContext alloc] initWithObject:object
                                                                              keyPath:self.bindKeyPath
                                                                        formatterName:self.bindFormatter
                                                                                 view:self];
            [self updateText];
        }
        else {
            HLSLoggerWarn(@"A binding path has been set for %@, but its class does not implement bindings", self);
        }
    }
    
    if ([self bindsRecursively]) {
        for (UIView *subview in self.subviews) {
            [subview bindToObject:object inViewController:viewController];
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

- (void)unbind
{
    // TODO:
}

- (void)refreshBindingsInViewController:(UIViewController *)viewController
{
    if (self.viewController && self.viewController != viewController) {
        return;
    }
    
    [self updateText];
    
    if ([self bindsRecursively]) {
        for (UIView *subview in self.subviews) {
            [subview refreshBindingsInViewController:viewController];
        }
    }
}

- (void)updateText
{
    if (! self.bindingContext) {
        return;
    }
    
    NSString *text = [self.bindingContext text];
    [self updateViewWithText:text];
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

- (id)bindingContext
{
    return objc_getAssociatedObject(self, s_bindingContextKey);
}

- (void)setBindingContext:(id)bindingContext
{
    objc_setAssociatedObject(self, s_bindingContextKey, bindingContext, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark Swizzled method implementations

static void swizzled_UIView__awakeFromNib_Imp(UIView *self, SEL _cmd)
{
    (*s_UIView__awakeFromNib_Imp)(self, _cmd);
    
    if (! self.bindingContext) {
        if (! self.bindKeyPath) {
            return;
        }
        
        if (! [self respondsToSelector:@selector(updateViewWithText:)]) {
            HLSLoggerWarn(@"A binding path has been set for %@, but its class does not implement bindings", self);
            return;
        }
        
        self.bindingContext = [[HLSViewObjectBindingContext alloc] initWithObject:nil keyPath:self.bindKeyPath formatterName:self.bindFormatter view:self];
        [self updateText];
    }
}
