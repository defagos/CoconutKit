//
//  HLSViewBindingInformation.m
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "HLSViewBindingInformation.h"

#import "HLSLogger.h"
#import "HLSMAKVONotificationCenter.h"
#import "HLSTransformer.h"
#import "NSArray+HLSExtensions.h"
#import "NSBundle+HLSExtensions.h"
#import "NSError+HLSExtensions.h"
#import "NSObject+HLSExtensions.h"
#import "NSString+HLSExtensions.h"
#import "UIView+HLSViewBinding.h"
#import "UIView+HLSViewBindingFriend.h"
#import "UIView+HLSViewBindingImplementation.h"

#import <objc/runtime.h>

typedef NS_OPTIONS(NSInteger, HLSViewBindingStatus) {
    HLSViewBindingStatusUnverified = 0,
    HLSViewBindingStatusObjectTargetResolved = (1 << 0),
    HLSViewBindingStatusTransformerResolved = (1 << 1),
    HLSViewBindingStatusDelegateResolved = (1 << 2),
    HLSViewBindingStatusTypeCompatibilityChecked = (1 << 3)
};

typedef NS_ENUM(NSInteger, HLSViewBindingError) {
    HLSViewBindingErrorInvalidKeyPath,
    HLSViewBindingErrorObjectTargetNotFound,
    HLSViewBindingErrorInvalidTransformer,
    HLSViewBindingErrorNilValue,
    HLSViewBindingErrorUnsupportedType,
    HLSViewBindingErrorUnsupportedOperation
};

@interface HLSViewBindingInformation ()

@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, strong) NSString *transformerName;
@property (nonatomic, weak) UIView *view;

@property (nonatomic, weak) id objectTarget;

@property (nonatomic, weak) id transformationTarget;
@property (nonatomic, assign) SEL transformationSelector;
@property (nonatomic, strong) NSObject<HLSTransformer> *transformer;

@property (nonatomic, weak) id<HLSViewBindingDelegate> delegate;

@property (nonatomic, assign) HLSViewBindingStatus status;

@property (nonatomic, assign, getter=isVerified) BOOL verified;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, assign, getter=isCheckingAutomatically) BOOL supportingInput;

@property (nonatomic, assign, getter=isViewAutomaticallyUpdated) BOOL viewAutomaticallyUpdated;
@property (nonatomic, assign, getter=isModelAutomaticallyUpdated) BOOL modelAutomaticallyUpdated;

// Used to prevent calls to checks / update methods when we are simply updating a view. Depending on how view update
// is performed, we namely could end up triggering an update which would yield to a view updated, and therefore
// to an infinite call chain
@property (nonatomic, assign, getter=isUpdatingView) BOOL updatingView;

// Same as above, but when updating the model
@property (nonatomic, assign, getter=isUpdatingModel) BOOL updatingModel;

@end

@implementation HLSViewBindingInformation

#pragma mark Object creation and destruction

- (instancetype)initWithKeyPath:(NSString *)keyPath
                transformerName:(NSString *)transformerName
                           view:(UIView *)view
{
    if (self = [super init]) {
        if (! [keyPath isFilled] || ! view) {
            HLSLoggerError(@"Binding requires at least a keypath and a view");
            return nil;
        }
        
        if (! view.bindingSupported) {
            HLSLoggerError(@"The view does not support bindings");
            return nil;
        }
        
        self.keyPath = keyPath;
        self.transformerName = transformerName;
        self.view = view;
        self.status = HLSViewBindingStatusUnverified;
        self.supportingInput = [view respondsToSelector:@selector(inputValue)];
    }
    return self;
}

- (void)dealloc
{
    // Unregister KVO
    self.objectTarget = nil;
}

#pragma mark Accessors and mutators

- (id)value
{
    if (! self.verified || self.error) {
        return nil;
    }
    
    id value = [self.objectTarget valueForKeyPath:self.keyPath];
    return [self transformValue:value];
}

- (id)rawValue
{
    @try {
        return [self.objectTarget valueForKeyPath:self.keyPath];
    }
    @catch (NSException *exception) {
        if ([exception.name isEqualToString:NSUndefinedKeyException]) {
            return nil;
        }
        else {
            @throw;
        }
    }
}

- (id)inputValue
{
    if ([self.view respondsToSelector:@selector(inputValue)]) {
        return [self.view performSelector:@selector(inputValue)];
    }
    else {
        return nil;
    }
}

- (void)setObjectTarget:(id)objectTarget
{
    if (_objectTarget && self.viewAutomaticallyUpdated) {
        [_objectTarget removeObserver:self keyPath:self.keyPath];
        
        self.viewAutomaticallyUpdated = NO;
    }
    
    _objectTarget = objectTarget;
    
    // KVO bug: Doing KVO on key paths containing keypath operators (which cannot be used with KVO) and catching the exception leads to retaining the
    // observer (though KVO itself neither retains the observer nor its observee). Catch such key paths before
    if (objectTarget && [self.keyPath rangeOfString:@"@"].length == 0) {
        [objectTarget addObserver:self keyPath:self.keyPath options:NSKeyValueObservingOptionNew block:^(HLSMAKVONotification *notification) {
            [self.view updateView];
        }];
        
        self.viewAutomaticallyUpdated = YES;
    }
}

#pragma mark Updating the view

- (void)updateViewAnimated:(BOOL)animated
{
    if (self.updatingModel) {
        return;
    }
    
    // Lazily check and fill binding information
    [self verifyBindingInformation];
    
    id value = nil;
    if ([self canDisplayPlaceholder]) {
        id rawValue = [self rawValue];
        if (rawValue && (! [rawValue isKindOfClass:[NSNumber class]] || ! [rawValue isEqualToNumber:@0])) {
            value = [self value];
        }
    }
    else {
        value = [self value];
    }
    
    self.updatingView = YES;
    
    void (*methodImp)(id, SEL, id, BOOL) = (void (*)(id, SEL, id, BOOL))[self.view methodForSelector:@selector(updateViewWithValue:animated:)];
    (*methodImp)(self.view, @selector(updateViewWithValue:animated:), value, animated);
    
    self.updatingView = NO;
}

#pragma mark Checking and updating values (these operations notify the delegate about their status)

/**
 * Try to transform back a value into a value which is compatible with the keypath. Return YES and the value iff the
 * reverse transformation could be achieved (the method always succeeds if no transformer has been specified).
 * Errors are returned to the binding delegate (if any) and to the caller
 */
- (BOOL)convertTransformedValue:(id)transformedValue toValue:(id *)pValue withError:(NSError *__autoreleasing *)pError
{
    // Skip when triggered by view update implementations
    if (self.updatingView) {
        return YES;
    }
    
    if (self.transformer) {
        BOOL success = YES;
        id value = nil;
        
        NSError *error = nil;
        NSError *detailedError = nil;
        
        if ([self.transformer respondsToSelector:@selector(getObject:fromObject:error:)]) {
            success = [self.transformer getObject:&value fromObject:transformedValue error:&detailedError];
        }
        else {
            detailedError = [NSError errorWithDomain:CoconutKitErrorDomain
                                                code:HLSErrorTransformationError
                                localizedDescription:CoconutKitLocalizedString(@"No reverse transformation is available", nil)];
            success = NO;
        }
        
        if (success) {
            if ([self.delegate respondsToSelector:@selector(boundView:transformationDidSucceedWithObject:)]) {
                [self.delegate boundView:self.view transformationDidSucceedWithObject:self.objectTarget];
            }
            
            if (pValue) {
                *pValue = value;
            }
        }
        else {
            error = [NSError errorWithDomain:CoconutKitErrorDomain
                                        code:HLSErrorTransformationError
                        localizedDescription:CoconutKitLocalizedString(@"Incorrect format", nil)];
            [error setUnderlyingError:detailedError];
            
            if ([self.delegate respondsToSelector:@selector(boundView:transformationDidFailWithObject:error:)]) {
                [self.delegate boundView:self.view transformationDidFailWithObject:self.objectTarget error:error];
            }
            
            if (pError) {
                *pError = error;
            }
        }
        
        return success;
    }
    else {
        if (pValue) {
            *pValue = transformedValue;
        }
        
        return YES;
    }
}

/**
 * Check whether a value is correct according to any validation which might have been set (validation is made through
 * KVO, see NSKeyValueCoding category on NSObject for more information). The method returns YES iff the check is
 * successful, otherwise the method returns NO, in which case errors are returned to the binding delegate (if any) and
 * to the caller
 */
- (BOOL)checkValue:(id)value withError:(NSError *__autoreleasing *)pError
{
    // Skip when triggered by view update implementations
    if (self.updatingView) {
        return YES;
    }
    
    NSError *error = nil;
    if ([self.objectTarget validateValue:&value forKeyPath:self.keyPath error:&error]) {
        if ([self.delegate respondsToSelector:@selector(boundView:checkDidSucceedWithObject:)]) {
            [self.delegate boundView:self.view checkDidSucceedWithObject:self.objectTarget];
        }
        return YES;
    }
    else {
        if ([self.delegate respondsToSelector:@selector(boundView:checkDidFailWithObject:error:)]) {
            [self.delegate boundView:self.view checkDidFailWithObject:self.objectTarget error:error];
        }
        
        if (pError) {
            *pError = error;
        }
        
        return NO;
    }
}

/**
 * Update the value which the key path points at with another value. Does not perform any check, -checkValue:withError:
 * must be called for that purpose. Returns YES iff the value could be updated, NO otherwise (e.g. if no setter is
 * available). Errors are returned to the validation delegate (if any) and to the caller
 */
- (BOOL)updateWithValue:(id)value error:(NSError *__autoreleasing *)pError
{
    // Skip when triggered by view update implementations
    if (self.updatingView) {
        return YES;
    }
    
    @try {
        self.updatingModel = YES;
        
        // Will throw when given nil for scalar values. Use 0 in such cases
        // See https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Protocols/NSKeyValueCoding_Protocol/index.html#//apple_ref/occ/instm/NSObject/setNilValueForKey:
        @try {
            [self.objectTarget setValue:value forKeyPath:self.keyPath];
        }
        @catch (NSException *exception) {
            if ([exception.name isEqualToString:NSInvalidArgumentException]) {
                [self.objectTarget setValue:@0 forKeyPath:self.keyPath];
            }
            else {
                @throw;
            }
        }
        
        // We might now have enough information to fully verify binding information, if not already the case
        [self verifyBindingInformation];
        
        self.updatingModel = NO;
    }
    @catch (NSException *exception) {
        if ([exception.name isEqualToString:NSUndefinedKeyException]) {
            NSError *error = [NSError errorWithDomain:CoconutKitErrorDomain
                                                 code:HLSErrorUpdateError
                                 localizedDescription:CoconutKitLocalizedString(@"The value cannot be updated", nil)];
            
            if ([self.delegate respondsToSelector:@selector(boundView:updateDidFailWithObject:error:)]) {
                [self.delegate boundView:self.view updateDidFailWithObject:self.objectTarget error:error];
            }
            
            if (pError) {
                *pError = error;
            }
            
            HLSLoggerError(@"Cannot update object %@ with value %@ for key path %@: %@", self.objectTarget, value, self.keyPath, exception);
            return NO;
        }
        else {
            @throw;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(boundView:updateDidSucceedWithObject:)]) {
        [self.delegate boundView:self.view updateDidSucceedWithObject:self.objectTarget];
    }
    
    return YES;
}

#pragma mark Binding

- (BOOL)resolveObjectTarget:(id *)pObjectTarget withError:(NSError *__autoreleasing *)pError
{
    id objectTarget = [HLSViewBindingInformation bindingTargetForKeyPath:self.keyPath view:self.view];
    if (! objectTarget) {
        if (pError) {
            *pError = [NSError errorWithDomain:CoconutKitErrorDomain
                                          code:HLSViewBindingErrorObjectTargetNotFound
                          localizedDescription:CoconutKitLocalizedString(@"No meaningful object target was found along the responder chain for the specified keypath (stopping at view controller boundaries)", nil)];
        }
        return NO;
    }
    
    // Verify setter existence (-set<name> according to KVO compliance rules). Keypaths containing operators cannot
    // be set
    // For more information, see https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/Compliant.html
    if (self.supportingInput) {
        if ([self.keyPath rangeOfString:@"@"].length == 0) {
            id setterObject = nil;
            NSString *setterName = nil;
            
            NSArray *keyPathComponents = [self.keyPath componentsSeparatedByString:@"."];
            if ([keyPathComponents count] > 1) {
                NSString *setObjectKeyPath = [[keyPathComponents arrayByRemovingLastObject] componentsJoinedByString:@"."];
                setterObject = [objectTarget valueForKeyPath:setObjectKeyPath];
                setterName = [keyPathComponents lastObject];
            }
            else {
                setterObject = objectTarget;
                setterName = [NSString stringWithFormat:@"set%@:", [self.keyPath stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                                                                         withString:[[self.keyPath substringToIndex:1] uppercaseString]]];
            }
            self.modelAutomaticallyUpdated = [setterObject respondsToSelector:NSSelectorFromString(setterName)];
        }
    }
    
    if (pObjectTarget) {
        *pObjectTarget = objectTarget;
    }
    
    return YES;
}

- (BOOL)resolveTransformationTarget:(id *)pTransformationTarget transformationSelector:(SEL *)pTransformationSelector withError:(NSError *__autoreleasing *)pError
{
    if (! [self.transformerName isFilled]) {
        if (pError) {
            *pError = [NSError errorWithDomain:CoconutKitErrorDomain
                                          code:HLSViewBindingErrorInvalidTransformer
                          localizedDescription:CoconutKitLocalizedString(@"No transformer has been specified", nil)];
        }
        return NO;
    }
    
    // Check whether the transformer is a global formatter (ClassName:formatterName)
    NSArray *transformerComponents = [self.transformerName componentsSeparatedByString:@":"];
    if ([transformerComponents count] > 2) {
        if (pError) {
            *pError = [NSError errorWithDomain:CoconutKitErrorDomain
                                          code:HLSViewBindingErrorInvalidTransformer
                          localizedDescription:CoconutKitLocalizedString(@"The specified transformer name syntax is invalid", nil)];
        }
        return NO;
    }
    
    id transformationTarget = nil;
    SEL transformationSelector = NULL;
    
    // Global formatter syntax used
    if ([transformerComponents count] == 2) {
        Class class = NSClassFromString([transformerComponents firstObject]);
        if (! class) {
            if (pError) {
                *pError = [NSError errorWithDomain:CoconutKitErrorDomain
                                              code:HLSViewBindingErrorInvalidTransformer
                              localizedDescription:CoconutKitLocalizedString(@"The specified transformer name points to an invalid class", nil)];
            }
            return NO;
        }
        transformationTarget = class;
        
        transformationSelector = NSSelectorFromString([transformerComponents objectAtIndex:1]);
        if (! transformationSelector || ! class_getClassMethod(class, transformationSelector)) {
            if (pError) {
                *pError = [NSError errorWithDomain:CoconutKitErrorDomain
                                              code:HLSViewBindingErrorInvalidTransformer
                              localizedDescription:CoconutKitLocalizedString(@"The specified global transformer method does not exist", nil)];
            }
            return NO;
        }
    }
    // Local formatter specified
    else {
        transformationSelector = NSSelectorFromString(self.transformerName);
        if (! transformationSelector) {
            if (pError) {
                *pError = [NSError errorWithDomain:CoconutKitErrorDomain
                                              code:HLSViewBindingErrorInvalidTransformer
                              localizedDescription:CoconutKitLocalizedString(@"The specified transformer method name is invalid", nil)];
            }
            return NO;
        }
        
        // Look along the responder chain first (most specific)
        transformationTarget = [HLSViewBindingInformation bindingTargetForSelector:transformationSelector view:self.view];
        if (! transformationTarget) {
            // Keypath ending with objects.@operator.field. Extract the class of objects and look for a transformer on it
            NSArray *keyPathComponents = [self.keyPath componentsSeparatedByString:@"."];
            if ([keyPathComponents count] >= 2 && [[keyPathComponents objectAtIndex:[keyPathComponents count] - 2] hasPrefix:@"@"]) {
                NSString *objectsKeyPath = [[[keyPathComponents arrayByRemovingLastObject] arrayByRemovingLastObject] componentsJoinedByString:@"."];
                
                // Only look for a class method since we have no single object here, but a collection. We assume that all
                // objects in the collection have the type of the first one
                id object = [[self.objectTarget valueForKeyPath:objectsKeyPath] firstObject];
                if ([[object class] respondsToSelector:transformationSelector]) {
                    transformationTarget = [object class];
                }
            }
            // Keypath ending with object.field (look for a transformer on 'object') or field (look for a transformer on 'objectTarget')
            else {
                NSArray *objectKeyPathComponents = [keyPathComponents arrayByRemovingLastObject];
                
                id object = nil;
                if ([objectKeyPathComponents count] == 0) {
                    object = self.objectTarget;
                }
                else {
                    NSString *objectKeyPath = [objectKeyPathComponents componentsJoinedByString:@"."];
                    object = [self.objectTarget valueForKeyPath:objectKeyPath];
                }
                
                // Look for an instance method on the object
                if ([object respondsToSelector:transformationSelector]) {
                    transformationTarget = object;
                }
                // Look for a class method on the object class itself (most generic)
                else if ([[object class] respondsToSelector:transformationSelector]) {
                    transformationTarget = [object class];
                }
            }
        }
    }
    
    if (! transformationTarget) {
        if (pError) {
            *pError = [NSError errorWithDomain:CoconutKitErrorDomain
                                          code:HLSViewBindingErrorInvalidTransformer
                          localizedDescription:CoconutKitLocalizedString(@"The specified transformer is neither a valid global transformer, "
                                                                         "nor could be resolved along the responder chain (stopping at view "
                                                                         "controller boundaries) or on the parent object", nil)];
        }
        return NO;
    }
    
    if (pTransformationTarget) {
        *pTransformationTarget = transformationTarget;
    }
    
    if (pTransformationSelector) {
        *pTransformationSelector = transformationSelector;
    }

    return YES;
}

- (BOOL)resolveTransformer:(id<HLSTransformer> *)pTransformer withTransformationTarget:(id)transformationTarget transformationSelector:(SEL)transformationSelector error:(NSError *__autoreleasing *)pError
{
    if (! transformationTarget) {
        return YES;
    }
    
    // Cannot use -performSelector here since the signature is not explicitly visible in the call for ARC to perform correct memory management
    id (*methodImp)(id, SEL) = (id (*)(id, SEL))[transformationTarget methodForSelector:transformationSelector];
    id transformer = methodImp(transformationTarget, transformationSelector);
    
    // Wrap native Foundation transformers into HLSTransformer instances
    if ([transformer isKindOfClass:[NSFormatter class]]) {
        transformer = [HLSBlockTransformer blockTransformerFromFormatter:transformer];
    }
    else if ([transformer isKindOfClass:[NSValueTransformer class]]) {
        transformer = [HLSBlockTransformer blockTransformerFromValueTransformer:transformer];
    }
    
    if (! [transformer conformsToProtocol:@protocol(HLSTransformer)]) {
        if (pError) {
            *pError = [NSError errorWithDomain:CoconutKitErrorDomain
                                          code:HLSViewBindingErrorInvalidTransformer
                          localizedDescription:CoconutKitLocalizedString(@"The specified transformer must either be an HLSTransformer, NSFormatter "
                                                                         "or NSValueTransformer instance", nil)];
        }
        return NO;
    }
    
    if (pTransformer) {
        *pTransformer = transformer;
    }
    
    return YES;
}

- (void)verifyBindingInformation
{
    if (self.verified) {
        return;
    }
    
    NSError *error = nil;
    
    if ((self.status & HLSViewBindingStatusObjectTargetResolved) == 0) {
        id objectTarget = nil;
        
        if ([self resolveObjectTarget:&objectTarget withError:&error]) {
            self.status |= HLSViewBindingStatusObjectTargetResolved;
            self.objectTarget = objectTarget;
        }
        else {
            self.verified = YES;
            self.error = error;
            return;
        }
    }
    
    if ([self.transformerName isFilled] && (self.status & HLSViewBindingStatusTransformerResolved) == 0) {
        id transformationTarget = nil;
        SEL transformationSelector = NULL;
        id<HLSTransformer> transformer = nil;
        
        if ([self resolveTransformationTarget:&transformationTarget transformationSelector:&transformationSelector withError:&error]
                && [self resolveTransformer:&transformer withTransformationTarget:transformationTarget transformationSelector:transformationSelector error:&error]) {
            self.status |= HLSViewBindingStatusTransformerResolved;
            self.transformationTarget = transformationTarget;
            self.transformationSelector = transformationSelector;
            self.transformer = transformer;
            
            // Observe transformer updates, reload cached transformer and update view accordingly
            __weak __typeof(self) weakSelf = self;
            [self.transformationTarget addObserver:self keyPath:NSStringFromSelector(self.transformationSelector) options:NSKeyValueObservingOptionNew block:^(HLSMAKVONotification *notification) {
                id<HLSTransformer> transformer = nil;
                NSError *error = nil;
                
                if ([weakSelf resolveTransformer:&transformer withTransformationTarget:weakSelf.transformationTarget transformationSelector:weakSelf.transformationSelector error:&error]) {
                    weakSelf.verified = NO;
                    weakSelf.error = error;
                }
                
                weakSelf.transformer = transformer;
                [weakSelf.view updateView];
            }];
        }
        else {
            self.verified = YES;
            self.error = error;
            return;
        }
    }
    
    if ((self.status & HLSViewBindingStatusDelegateResolved) == 0) {
        self.delegate = [HLSViewBindingInformation delegateForView:self.view];
        self.status |= HLSViewBindingStatusDelegateResolved;
    }
    
    if ((self.status & HLSViewBindingStatusTypeCompatibilityChecked) == 0) {
        // No need to check for exceptions here, the keypath is here guaranteed to be valid for the object
        id value = [self.objectTarget valueForKeyPath:self.keyPath];
        id inputValue = [self transformValue:value];
        
        // Cannot verify further yet
        if (! inputValue) {
            self.error = [NSError errorWithDomain:CoconutKitErrorDomain
                                             code:HLSViewBindingErrorNilValue
                             localizedDescription:CoconutKitLocalizedString(@"Type compliance cannot be verified yet since the value to display is nil", nil)];
            return;
        }
        
        if ([self canDisplayValue:inputValue]) {
            self.status |= HLSViewBindingStatusTypeCompatibilityChecked;
        }
        else {
            NSString *localizedDescription = nil;
            
            if (self.transformer) {
                localizedDescription = [NSString stringWithFormat:CoconutKitLocalizedString(@"The transformer must return one of the following "
                                                                                            "supported types: %@", nil), [self supportedBindingClassesString]];
            }
            else {
                localizedDescription = [NSString stringWithFormat:CoconutKitLocalizedString(@"The keypath must return one of the following supported types: %@. Fix the return type "
                                                                                            "or use a transformer", nil), [self supportedBindingClassesString]];
            }
            
            self.verified = YES;
            self.error = [NSError errorWithDomain:CoconutKitErrorDomain
                                             code:HLSViewBindingErrorUnsupportedType
                             localizedDescription:localizedDescription];
            return;
        }
    }
    
    self.verified = YES;
    self.error = nil;
}

#pragma mark Type checking

- (NSArray *)supportedBindingClasses
{
    Class viewClass = [self.view class];
    
    if ([viewClass respondsToSelector:@selector(supportedBindingClasses)]) {
        return [viewClass supportedBindingClasses];
    }
    else {
        return @[[NSString class]];
    }
}

- (NSString *)supportedBindingClassesString
{
    NSArray *supportedBindingClasses = [self supportedBindingClasses];
    NSMutableArray *classNames = [NSMutableArray array];
    for (Class supportedBindingClass in supportedBindingClasses) {
        [classNames addObject:NSStringFromClass(supportedBindingClass)];
    }
    return [classNames componentsJoinedByString:@", "];
}

- (BOOL)canDisplayValue:(id)value
{
    NSArray *supportedBindingClasses = [self supportedBindingClasses];
    for (Class supportedBindingClass in supportedBindingClasses) {
        if ([value isKindOfClass:supportedBindingClass]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)canDisplayPlaceholder
{
    Class viewClass = [self.view class];
    
    if ([viewClass respondsToSelector:@selector(canDisplayPlaceholder)]) {
        return [viewClass canDisplayPlaceholder];
    }
    else {
        return NO;
    }
}

#pragma mark Transformation

- (id)transformValue:(id)value
{
    return self.transformer ? [self.transformer transformObject:value] : value;
}

#pragma mark Context binding lookup

// Always start, not with the view, but with its next responder. Binding namely makes sense with a parent context
// (not in the context of the bound view itself). Moreover, this avoids collisions between the keypath to bind and
// view properties bearing the same name (e.g. a property called 'text' bound to a text field would be trapped
// otherwise be resolved on the text field itself)
+ (id<HLSViewBindingDelegate>)delegateForView:(UIView *)view
{
    UIResponder *responder = view.nextResponder;
    while (responder) {
        if ([responder conformsToProtocol:@protocol(HLSViewBindingDelegate)]) {
            return (id<HLSViewBindingDelegate>)responder;
        }
        
        // Does not get higher than the receiver parent view controller, which defines the binding context
        if ([responder isKindOfClass:[UIViewController class]]) {
            return nil;
        }
        
        responder = responder.nextResponder;
    }
    return nil;
}

// Locate the target which implements the specified method. Stops at view controller boundaries
+ (id)bindingTargetForSelector:(SEL)selector view:(UIView *)view
{
    UIResponder *responder = view.nextResponder;
    while (responder) {
        // Instance method lookup first
        if ([responder respondsToSelector:selector]) {
            return responder;
        }
        
        // Class method lookup
        Class responderClass = [responder class];
        if ([responderClass respondsToSelector:selector]) {
            return responderClass;
        }
        
        // Does not get higher than the receiver parent view controller, which defines the binding context
        if ([responder isKindOfClass:[UIViewController class]]) {
            return nil;
        }
        
        responder = responder.nextResponder;
    }
    return nil;
}

+ (id)bindingTargetForKeyPath:(NSString *)keyPath view:(UIView *)view
{
    UIResponder *responder = view.nextResponder;
    while (responder) {
        @try {
            // Will throw an exception unless the keypath is valid
            [responder valueForKeyPath:keyPath];
            return responder;
        }
        @catch (NSException *exception) {
            if ([exception.name isEqualToString:NSUndefinedKeyException]) {
                // Does not get higher than the receiver parent view controller, which defines the binding context
                if ([responder isKindOfClass:[UIViewController class]]) {
                    return nil;
                }
                
                responder = responder.nextResponder;
            }
            else {
                @throw;
            }
        }
    }
    return nil;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; objectTarget: %@; keyPath: %@; transformerName: %@; transformationTarget: %@; transformationSelector:%@>",
            [self class],
            self,
            self.objectTarget,
            self.keyPath,
            self.transformerName,
            self.transformationTarget,
            NSStringFromSelector(self.transformationSelector)];
}

@end

@implementation HLSViewBindingInformation (ConvenienceMethods)

- (BOOL)check:(BOOL)check andUpdate:(BOOL)update withCurrentInputValueError:(NSError *__autoreleasing *)pError
{
    return [self check:check andUpdate:update withInputValue:[self inputValue] error:pError];
}

- (BOOL)check:(BOOL)check andUpdate:(BOOL)update withInputValue:(id)inputValue error:(NSError *__autoreleasing *)pError
{
    // Skip when triggered by view update implementations
    if (self.updatingView) {
        return YES;
    }
    
    if (! self.supportingInput) {
        if (pError) {
            *pError = [NSError errorWithDomain:CoconutKitErrorDomain
                                          code:HLSViewBindingErrorUnsupportedOperation
                          localizedDescription:CoconutKitLocalizedString(@"The view does not support input", nil)];
        }
        return NO;
    }
    
    if (! [self canDisplayValue:inputValue]) {
        if (pError) {
            *pError = [NSError errorWithDomain:CoconutKitErrorDomain
                                          code:HLSErrorUnsupportedTypeError
                          localizedDescription:CoconutKitLocalizedString(@"The type of the input value is not supported", nil)];
        }
        return NO;
    }
    
    id value = nil;
    NSError *error = nil;
    
    BOOL success = [self convertTransformedValue:inputValue toValue:&value withError:&error];
    if (success) {
        NSError *checkError = nil;
        if (check && ! [self checkValue:value withError:&checkError]) {
            success = NO;
            [NSError combineError:checkError withError:&error];
        }
        
        NSError *updateError = nil;
        if (update && ! [self updateWithValue:value error:&updateError]) {
            success = NO;
            [NSError combineError:updateError withError:&error];
        }
    }
    
    if (pError) {
        *pError = error;
    }
    
    return success;
}

@end
