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
#import "HLSRuntime.h"
#import "HLSTransformer.h"
#import "HLSViewBindingError.h"
#import "NSArray+HLSExtensions.h"
#import "NSBundle+HLSExtensions.h"
#import "NSError+HLSExtensions.h"
#import "NSObject+HLSExtensions.h"
#import "NSString+HLSExtensions.h"
#import "UIView+HLSViewBinding.h"
#import "UIView+HLSViewBindingFriend.h"
#import "UIView+HLSViewBindingImplementation.h"

/**
 * Internal status flag. Use to avoid performing already successful binding verification steps
 */
typedef NS_OPTIONS(NSInteger, HLSViewBindingStatus) {
    HLSViewBindingStatusUnverified = 0,                                 // Binding never verified
    HLSViewBindingStatusTypeResolved = (1 << 0),                        // Type has been resolved (might have found nothing reliable)
    HLSViewBindingStatusObjectTargetResolved = (1 << 1),                // Binding target resolution has been successfully made
    HLSViewBindingStatusTransformerResolved = (1 << 2),                 // Binding transformer resolution has been successfully made (might have found nothing)
    HLSViewBindingStatusDelegateResolved = (1 << 3),                    // Binding delegate resoution has been successfully made (might have found nothing)
    HLSViewBindingStatusTypeCompatibilityChecked = (1 << 4)             // Type compatibility with the view has been checked
};

@interface HLSViewBindingInformation ()

@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, strong) NSString *transformerName;
@property (nonatomic, weak) UIView *view;

@property (nonatomic, weak) id objectTarget;
@property (nonatomic, assign) Class rawClass;

@property (nonatomic, weak) id transformationTarget;
@property (nonatomic, assign) SEL transformationSelector;
@property (nonatomic, strong) NSObject<HLSTransformer> *transformer;

@property (nonatomic, weak) id<HLSViewBindingDelegate> delegate;

@property (nonatomic, assign) HLSViewBindingStatus status;

@property (nonatomic, assign, getter=isVerified) BOOL verified;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, assign, getter=isSupportingInput) BOOL supportingInput;

@property (nonatomic, assign, getter=isViewAutomaticallyUpdated) BOOL viewAutomaticallyUpdated;
@property (nonatomic, assign, getter=isModelAutomaticallyUpdated) BOOL modelAutomaticallyUpdated;

// Used to prevent recursive calls to checks / update methods when we are simply updating a view. Depending on how view update
// is performed, we namely could end up triggering an update which would yield to a view updated, and therefore to an infinite
// call chain
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
    return self.transformer ? [self.transformer transformObject:value] : value;
}

- (id)rawValue
{
    if ((self.status & HLSViewBindingStatusObjectTargetResolved) == 0) {
        return nil;
    }
    
    return [self.objectTarget valueForKeyPath:self.keyPath];
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
            [self.view updateBoundView];
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
    [self verify];
    
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
    
    void (*methodImp)(id, SEL, id, BOOL) = (__typeof(methodImp))[self.view methodForSelector:@selector(updateViewWithValue:animated:)];
    (*methodImp)(self.view, @selector(updateViewWithValue:animated:), value, animated);
    
    self.updatingView = NO;
}

#pragma mark Transforming, checking and updating values (these operations notify the delegate about their status)

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
            detailedError = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                                code:HLSViewBindingErrorTransformation
                                localizedDescription:@"No reverse transformation is available"];
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
            error = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                        code:HLSViewBindingErrorTransformation
                        localizedDescription:@"Incorrect format"];
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
 * Update the value which the key path points at with another value. Returns YES iff the value could be updated, NO 
 * otherwise (e.g. if no setter is available). Errors are returned to the validation delegate (if any) and to the caller
 */
- (BOOL)updateWithValue:(id)value error:(NSError *__autoreleasing *)pError
{
    // Skip when triggered by view update implementations
    if (self.updatingView) {
        return YES;
    }
    
    @try {
        self.updatingModel = YES;
        
        if (! self.modelAutomaticallyUpdated) {
            @throw [NSException exceptionWithName:NSUndefinedKeyException
                                           reason:@"The model does not support updates"
                                         userInfo:nil];
        }
        
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
        [self verify];
        
        self.updatingModel = NO;
    }
    @catch (NSException *exception) {
        if ([exception.name isEqualToString:NSUndefinedKeyException]) {
            NSError *error = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                                 code:HLSViewBindingErrorUnsupportedOperation
                                 localizedDescription:@"The value cannot be updated"];
            NSError *detailedError = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                                         code:HLSViewBindingErrorUnsupportedOperation
                                         localizedDescription:exception.reason];
            [error setUnderlyingError:detailedError];
            
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

- (BOOL)check:(BOOL)check update:(BOOL)update withError:(NSError *__autoreleasing *)pError
{
    return [self check:check update:update withInputValue:[self inputValue] error:pError];
}

- (BOOL)check:(BOOL)check update:(BOOL)update withInputValue:(id)inputValue error:(NSError *__autoreleasing *)pError
{
    NSAssert(check || update, @"The method should at least check or update");
        
    // Skip when triggered by view update implementations
    if (self.updatingView) {
        return YES;
    }
    
    if (! self.supportingInput) {
        if (pError) {
            *pError = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                          code:HLSViewBindingErrorUnsupportedOperation
                          localizedDescription:@"The view does not support input"];
        }
        return NO;
    }
    
    if (! [self canDisplayValue:inputValue]) {
        if (pError) {
            *pError = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                          code:HLSViewBindingErrorUnsupportedType
                          localizedDescription:@"The type of the input value is not supported"];
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

#pragma mark Binding

- (BOOL)resolveObjectTarget:(id *)pObjectTarget withError:(NSError *__autoreleasing *)pError
{
    id objectTarget = [HLSViewBindingInformation bindingTargetForKeyPath:self.keyPath view:self.view];
    if (! objectTarget) {
        if (pError) {
            *pError = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                          code:HLSViewBindingErrorObjectTargetNotFound
                          localizedDescription:@"No meaningful object target was found along the responder chain for "
                       "the specified key path (stopping at view controller boundaries)"];
        }
        return NO;
    }
    
    if (pObjectTarget) {
        *pObjectTarget = objectTarget;
    }
    
    return YES;
}

- (BOOL)resolveTransformationTarget:(id *)pTransformationTarget transformationSelector:(SEL *)pTransformationSelector withError:(NSError *__autoreleasing *)pError
{
    NSAssert([self.transformerName isFilled], @"A transformer name must be specified");
    
    // Check whether the transformer is a global formatter (ClassName:formatterName)
    NSArray *transformerComponents = [self.transformerName componentsSeparatedByString:@":"];
    if ([transformerComponents count] > 2) {
        if (pError) {
            *pError = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                          code:HLSViewBindingErrorInvalidTransformer
                          localizedDescription:@"The specified transformer name syntax is invalid"];
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
                *pError = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                              code:HLSViewBindingErrorInvalidTransformer
                              localizedDescription:@"The specified transformer name points to an invalid class"];
            }
            return NO;
        }
        transformationTarget = class;
        
        transformationSelector = NSSelectorFromString([transformerComponents objectAtIndex:1]);
        if (! transformationSelector || ! class_getClassMethod(class, transformationSelector)) {
            if (pError) {
                *pError = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                              code:HLSViewBindingErrorInvalidTransformer
                              localizedDescription:@"The specified global transformer method does not exist"];
            }
            return NO;
        }
    }
    // Local transformer specified
    else {
        transformationSelector = NSSelectorFromString(self.transformerName);
        if (! transformationSelector) {
            if (pError) {
                *pError = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                              code:HLSViewBindingErrorInvalidTransformer
                              localizedDescription:@"The specified transformer method name is invalid"];
            }
            return NO;
        }
        
        // Look along the responder chain first (most specific)
        transformationTarget = [HLSViewBindingInformation transformationTargetForSelector:transformationSelector view:self.view];
        if (! transformationTarget) {
            id lastTargetInKeyPath = [HLSViewBindingInformation lastTargetInKeyPath:self.keyPath withObject:self.objectTarget];
            if ([lastTargetInKeyPath respondsToSelector:transformationSelector]) {
                transformationTarget = lastTargetInKeyPath;
            }
            else if (! hls_isClass(lastTargetInKeyPath)) {
                Class lastTargetInKeyPathClass = [lastTargetInKeyPath class];
                if ([lastTargetInKeyPathClass respondsToSelector:transformationSelector]) {
                    transformationTarget = lastTargetInKeyPathClass;
                }
            }
        }
    }
    
    if (! transformationTarget) {
        if (pError) {
            *pError = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                          code:HLSViewBindingErrorInvalidTransformer
                          localizedDescription:@"The specified transformer is neither a valid global transformer, "
                       "nor could be resolved along the responder chain (stopping at view controller boundaries) or on "
                       "the parent object"];
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
    NSAssert(transformationTarget != nil && transformationSelector != NULL, @"A transformation target and / or selector must be specified");
    
    // Cannot use -performSelector here since the signature is not explicitly visible in the call for ARC to perform correct memory management
    id (*methodImp)(id, SEL) = (__typeof(methodImp))[transformationTarget methodForSelector:transformationSelector];
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
            *pError = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                          code:HLSViewBindingErrorInvalidTransformer
                          localizedDescription:@"The specified transformer must either be an HLSTransformer, NSFormatter "
                       "or NSValueTransformer instance"];
        }
        return NO;
    }
    
    if (pTransformer) {
        *pTransformer = transformer;
    }
    
    return YES;
}

- (void)verify
{
    if (self.verified) {
        return;
    }
    
    if ((self.status & HLSViewBindingStatusObjectTargetResolved) == 0) {
        id objectTarget = nil;
        NSError *error = nil;
        
        if ([self resolveObjectTarget:&objectTarget withError:&error]) {
            self.status |= HLSViewBindingStatusObjectTargetResolved;
            self.objectTarget = objectTarget;
        }
        else {
            self.verified = YES;
            self.error = error;
            return;
        }
        
        // Verify setter existence (-set<name> according to KVO compliance rules). Keypaths containing operators cannot
        // be set
        // For more information, see https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/Compliant.html
        if (self.supportingInput) {
            id lastTargetInKeyPath = [HLSViewBindingInformation lastTargetInKeyPath:self.keyPath withObject:self.objectTarget];
            if (! hls_isClass(lastTargetInKeyPath)) {
                NSString *methodName = [[self.keyPath componentsSeparatedByString:@"."] lastObject];
                NSString *setterName = [NSString stringWithFormat:@"set%@:", [methodName stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                                                                                 withString:[[methodName substringToIndex:1] uppercaseString]]];
                self.modelAutomaticallyUpdated = [lastTargetInKeyPath respondsToSelector:NSSelectorFromString(setterName)];
            }
        }
    }
    
    if ((self.status & HLSViewBindingStatusTypeResolved) == 0) {
        id lastTargetInKeyPath = [HLSViewBindingInformation lastTargetInKeyPath:self.keyPath withObject:self.objectTarget];
        NSString *methodName = [[self.keyPath componentsSeparatedByString:@"."] lastObject];
        
        Class lastTargetInKeyPathClass = hls_isClass(lastTargetInKeyPath) ? lastTargetInKeyPath : [lastTargetInKeyPath class];
        objc_property_t property = class_getProperty(lastTargetInKeyPathClass, [methodName UTF8String]);
        
        // If the method name corresponds to a property, reliable return type information can be obtained from the runtime. No such information
        // can be obtained for a getter or a getter / setter pair
        // See https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
        if (property) {
            const char *propertyAttributes = property_getAttributes(property);
            NSString *returnInformationString = [[[NSString stringWithUTF8String:propertyAttributes] componentsSeparatedByString:@","] firstObject];
            
            NSString *type = [returnInformationString substringWithRange:NSMakeRange(1, 1)];
            
            // Objects with a specified class
            if ([type isEqualToString:@"@"] && [returnInformationString length] > 2) {
                NSString *rawClassName = [returnInformationString substringWithRange:NSMakeRange(3, [returnInformationString length] - 4)];
                self.rawClass = NSClassFromString(rawClassName);
            }
            // Primitive types corresponding to numbers
            else if ([@"cdfiIls" rangeOfString:type].length != 0) {
                self.rawClass = [NSNumber class];
            }
        }
        
        self.status |= HLSViewBindingStatusTypeResolved;
    }
    
    if ((self.status & HLSViewBindingStatusTransformerResolved) == 0) {
        if ([self.transformerName isFilled]) {
            id transformationTarget = nil;
            SEL transformationSelector = NULL;
            id<HLSTransformer> transformer = nil;
            NSError *error = nil;
            
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
                    [weakSelf.view updateBoundView];
                }];
            }
            else {
                self.verified = YES;
                self.error = error;
                return;
            }
        }
        else {
            self.status |= HLSViewBindingStatusTransformerResolved;
        }
    }
    
    if ((self.status & HLSViewBindingStatusDelegateResolved) == 0) {
        self.delegate = [HLSViewBindingInformation delegateForView:self.view];
        self.status |= HLSViewBindingStatusDelegateResolved;
    }
    
    if ((self.status & HLSViewBindingStatusTypeCompatibilityChecked) == 0) {
        // No need to check for exceptions here, the keypath is here guaranteed to be valid for the object
        id rawValue = [self.objectTarget valueForKeyPath:self.keyPath];
        
        if (self.transformer) {
            id value = [self.transformer transformObject:rawValue];
            
            // Cannot verify further
            if (! value) {
                self.error = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                                 code:HLSViewBindingErrorNilValue
                                 localizedDescription:@"Type compliance cannot be verified yet since the value to display is nil"];
                return;
            }
            
            if (! [self canDisplayValue:value]) {
                self.verified = YES;
                self.error = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                                 code:HLSViewBindingErrorUnsupportedType
                                 localizedDescription:[NSString stringWithFormat:@"The transformer must return one of the following supported "
                                                       "types: %@", [self supportedBindingClassesString]]];
                return;
            }
        }
        else {
            // Reliable type information available. Check
            if (self.rawClass) {
                if (! [self canDisplayClass:self.rawClass]) {
                    self.verified = YES;
                    self.error = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                                     code:HLSViewBindingErrorUnsupportedType
                                     localizedDescription:[NSString stringWithFormat:@"A transformer is required to transform %@ into "
                                                           "one of the following types: %@", self.rawClass, [self supportedBindingClassesString]]];
                    return;
                }
            }
            else {
                // Cannot verify further
                if (rawValue) {
                    if (! [self canDisplayValue:rawValue]) {
                        self.verified = YES;
                        self.error = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                                         code:HLSViewBindingErrorUnsupportedType
                                         localizedDescription:[NSString stringWithFormat:@"The transformer must return one of the following supported "
                                                               "types: %@", [self supportedBindingClassesString]]];
                        return;
                    }
                    
                    // Even if the view is compatible, we have no way to tell a transformer is not missing
                    self.error = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                                     code:HLSViewBindingErrorMissingType
                                     localizedDescription:@"Type information is not available. Cannot tell if a transformer is missing, "
                                  "be careful. If you can, bind to a property instead of a getter / setter pair to get reliable type checking"];
                    return;
                }
                else {
                    self.error = [NSError errorWithDomain:HLSViewBindingErrorDomain
                                                     code:HLSViewBindingErrorNilValue
                                     localizedDescription:@"Type compliance cannot be verified yet since the value to display is nil"];
                    return;
                }
            }
        }
        
        self.status |= HLSViewBindingStatusTypeCompatibilityChecked;
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

- (BOOL)canDisplayClass:(Class)class
{
    NSArray *supportedBindingClasses = [self supportedBindingClasses];
    for (Class supportedBindingClass in supportedBindingClasses) {
        if (hls_class_isSubclassOfClass(class, supportedBindingClass)) {
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

#pragma mark Context binding lookup along the responder chain

/**
 * Locate the binding delegate along the responder chain. Always start, not with the view, but with its next 
 * responder. Binding namely makes sense with a parent context (not in the context of the bound view itself). 
 * Moreover, this avoids collisions between the keypath to bind and view properties bearing the same name 
 * (e.g. a property called 'text' bound to a text field would be trapped by the text field text property).
 * Lookup stops at view controller boundaries
 */
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

/**
 * Locate a transformation target along the responder chain. The transformation selector can either be a class or
 * instance method. Lookup stops at view controller boundaries
 */
+ (id)transformationTargetForSelector:(SEL)selector view:(UIView *)view
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

/**
 * Locate an object binding to the specified key path along the responder chain. Lookup stops at view controller
 * boundaries
 */
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

#pragma mark Key path information extraction

// Return the last object designated by a key path (before the final field)
+ (id)lastObjectInKeyPath:(NSString *)keyPath withObject:(id)object
{
    NSArray *keyPathComponents = [keyPath componentsSeparatedByString:@"."];
    
    // Simple key path field
    if ([keyPathComponents count] == 1) {
        return object;
    }
    // Key path ending with an operator. Extract objects onto which the key path is applied
    else if ([keyPathComponents count] >= 2 && [[keyPathComponents objectAtIndex:[keyPathComponents count] - 2] hasPrefix:@"@"]) {
        NSString *lastObjectsKeyPath = [[[keyPathComponents arrayByRemovingLastObject] arrayByRemovingLastObject] componentsJoinedByString:@"."];
        return [object valueForKeyPath:lastObjectsKeyPath];
    }
    // Composed key path object1.object2.(...).field
    else {
        NSString *lastObjectKeyPath = [[keyPathComponents arrayByRemovingLastObject] componentsJoinedByString:@"."];
        return [object valueForKeyPath:lastObjectKeyPath];
    }
}

// Return the last object designated by a key path (before the final field), or a class if it is a collection (the method
// assumes all objects have the same type and return the class of one of them)
+ (id)lastTargetInKeyPath:(NSString *)keyPath withObject:(id)object
{
    id lastObjectInKeyPath = [self lastObjectInKeyPath:keyPath withObject:object];
    
    // Collection
    if ([lastObjectInKeyPath respondsToSelector:@selector(objectEnumerator)]) {
        id collectionObject = [[lastObjectInKeyPath objectEnumerator] nextObject];
        return [collectionObject class];
    }
    // Single object
    else {
        return lastObjectInKeyPath;
    }
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
