//
//  NSError+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 27.12.11.
//  Copyright (c) 2011 Samuel Défago. All rights reserved.
//

#import "NSError+HLSExtensions.h"

#import "HLSAssert.h"
#import "HLSCoreError.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "NSBundle+HLSExtensions.h"
#import "NSDictionary+HLSExtensions.h"

NSString * const HLSDetailedErrorsKey = @"HLSDetailedErrorsKey";

static void *s_mutableUserInfoKey = &s_mutableUserInfoKey;

// Dynamic subclass method implementations
static NSDictionary *subclass_userInfo(id self, SEL _cmd);
static Class subclass_class(id self, SEL _cmd);

@implementation NSError (HLSExtensions)

#pragma mark Class methods

+ (instancetype)errorWithDomain:(NSString *)domain code:(NSInteger)code
{
    return [[[self class] alloc] initWithDomain:domain code:code];
}

+ (instancetype)errorWithDomain:(NSString *)domain code:(NSInteger)code localizedDescription:(NSString *)localizedDescription
{
    NSDictionary *userInfo = localizedDescription ? @{ NSLocalizedDescriptionKey : localizedDescription} : nil;
    return [[[self class] alloc] initWithDomain:domain code:code userInfo:userInfo];
}

+ (NSError *)combineError:(NSError *)newError withError:(NSError *__autoreleasing *)pExistingError
{
    // If the caller is not interested in errors, nothing to do
    if (! pExistingError) {
        return nil;
    }
    
    // If no new error, nothing to do
    if (! newError) {
        return *pExistingError;
    }
    
    if (*pExistingError) {
        if ([*pExistingError hasCode:HLSCoreErrorMultipleErrors withinDomain:HLSCoreErrorDomain]) {
            [*pExistingError addObject:newError forKey:HLSDetailedErrorsKey];
        }
        else {
            NSError *previousError = *pExistingError;
            *pExistingError = [NSError errorWithDomain:HLSCoreErrorDomain
                                                  code:HLSCoreErrorMultipleErrors
                                  localizedDescription:CoconutKitLocalizedString(@"Multiple errors have been encountered", nil)];
            [*pExistingError addObject:previousError forKey:HLSDetailedErrorsKey];
            [*pExistingError addObject:newError forKey:HLSDetailedErrorsKey];
        }
    }
    else {
        *pExistingError = newError;
    }
    
    return *pExistingError;
}

#pragma mark Object creation and destruction

- (instancetype)initWithDomain:(NSString *)domain code:(NSInteger)code
{
    return [self initWithDomain:domain code:code userInfo:nil];
}

#pragma mark Accessors and mutators

- (NSError *)underlyingError
{
    return [self objectForKey:NSUnderlyingErrorKey];
}

- (id)objectForKey:(NSString *)key
{
    if (! key) {
        HLSLoggerError(@"Missing key");
        return nil;
    }
    
    return [[self userInfo] objectForKey:key];
}

- (NSArray *)objectsForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    if (! object) {
        return nil;
    }
    
    if ([object isKindOfClass:[NSArray class]]) {
        return object;
    }
    else {
        return @[object];
    }
}

- (NSDictionary *)customUserInfo
{
    NSMutableDictionary *customUserInfo = [NSMutableDictionary dictionaryWithDictionary:[self userInfo]];
    [customUserInfo removeObjectForKey:NSLocalizedDescriptionKey];
    [customUserInfo removeObjectForKey:NSLocalizedFailureReasonErrorKey];
    [customUserInfo removeObjectForKey:NSLocalizedRecoverySuggestionErrorKey];
    [customUserInfo removeObjectForKey:NSLocalizedRecoveryOptionsErrorKey];
    [customUserInfo removeObjectForKey:NSRecoveryAttempterErrorKey];
    [customUserInfo removeObjectForKey:NSHelpAnchorErrorKey];
    [customUserInfo removeObjectForKey:NSUnderlyingErrorKey];
    return [NSDictionary dictionaryWithDictionary:customUserInfo];
}

- (NSMutableDictionary *)mutableUserInfo
{
    NSMutableDictionary *mutableUserInfo = hls_getAssociatedObject(self, s_mutableUserInfoKey);
    if (! mutableUserInfo) {
        mutableUserInfo = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
        
        // NSError is immutable, but this makes it rather inconvenient to use (you must set all information
        // as a dictionary when the error is created). This category adds a set of mutators which let you
        // set error information after creation (this information should not be altered anymore after the
        // error has been returned to the caller, of course). This behavior requires an additional mutable
        // dictionary, which we add by dynamic subclassing only if a mutator is used
        static NSString * const kSubclassSuffix = @"_HLSExtensions";
        
        // Access the real class, do not use [self class] here since can be faked
        Class class = object_getClass(self);
        NSString *className = [NSString stringWithUTF8String:class_getName(class)];
        if (! [className hasSuffix:kSubclassSuffix]) {
            NSString *subclassName = [className stringByAppendingString:kSubclassSuffix];
            Class subclass = NSClassFromString(subclassName);
            if (! subclass) {
                subclass = objc_allocateClassPair(class, [subclassName UTF8String], 0);
                NSAssert(subclass != Nil, @"Could not register subclass");
                class_addMethod(subclass,
                                @selector(userInfo),
                                (IMP)subclass_userInfo,
                                method_getTypeEncoding(class_getClassMethod(class, @selector(userInfo))));
                class_addMethod(subclass,
                                @selector(class),
                                (IMP)subclass_class,
                                method_getTypeEncoding(class_getClassMethod(class, @selector(class))));
                objc_registerClassPair(subclass);
            }
            
            // Changes the object class
            object_setClass(self, subclass);
        }
        
        hls_setAssociatedObject(self, s_mutableUserInfoKey, mutableUserInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return mutableUserInfo;
}

- (void)setLocalizedDescription:(NSString *)localizedDescription
{
    [self setObject:localizedDescription forKey:NSLocalizedDescriptionKey];
}

- (void)setLocalizedFailureReason:(NSString *)localizedFailureReason
{
    [self setObject:localizedFailureReason forKey:NSLocalizedFailureReasonErrorKey];
}

- (void)setLocalizedRecoverySuggestion:(NSString *)localizedRecoverySuggestion
{
    [self setObject:localizedRecoverySuggestion forKey:NSLocalizedRecoverySuggestionErrorKey];
}

- (void)setLocalizedRecoveryOptions:(NSArray *)localizedRecoveryOptions
{
    HLSAssertObjectsInEnumerationAreKindOfClass(localizedRecoveryOptions, NSString);
    
    [self setObject:localizedRecoveryOptions forKey:NSLocalizedRecoveryOptionsErrorKey];
}

- (void)setRecoveryAttempter:(id)recoveryAttempter
{
    [self setObject:recoveryAttempter forKey:NSRecoveryAttempterErrorKey];
}

- (void)setHelpAnchor:(NSString *)helpAnchor
{
    [self setObject:helpAnchor forKey:NSHelpAnchorErrorKey];
}

- (void)setUnderlyingError:(NSError *)underlyingError
{
    [self setObject:underlyingError forKey:NSUnderlyingErrorKey];
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    if (! key || ! object) {
        return;
    }
    
    if (object) {
        [[self mutableUserInfo] setObject:object forKey:key];
    }
    else {
        [[self mutableUserInfo] removeObjectForKey:key];
    }
}

- (void)addObject:(id)object forKey:(NSString *)key
{
    if (! key || ! object) {
        return;
    }
    
    [self addObjects:@[object] forKey:key];
}

- (void)addObjects:(NSArray *)objects forKey:(NSString *)key
{
    if ([objects count] == 0 || ! key) {
        return;
    }
    
    id existingObject = [self objectForKey:key];
    if (existingObject) {
        id existingObjects = [existingObject isKindOfClass:[NSArray class]] ? existingObject : @[existingObject];
        [self setObject:[existingObjects arrayByAddingObjectsFromArray:objects] forKey:key];
    }
    else {
        [self setObject:[objects firstObject] forKey:key];
    }
}

#pragma mark Comparison

- (BOOL)hasCode:(NSInteger)code withinDomain:(NSString *)domain
{
    return [self code] == code && [[self domain] isEqualToString:domain];
}

@end

#pragma mark Dynamic subclass method implementations

static NSDictionary *subclass_userInfo(NSError *self, SEL _cmd)
{
    return [NSDictionary dictionaryWithDictionary:[self mutableUserInfo]];
}

static Class subclass_class(NSError *self, SEL _cmd)
{
    // Lie about the dynamic subclass existence, as the KVO implementation does (the real class can still be seen
    // using object_getClass)
    return class_getSuperclass(object_getClass(self));
}
