//
//  HLSError.m
//  CoconutKit
//
//  Created by Samuel Défago on 10.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSError.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import "NSDictionary+HLSExtensions.h"

@interface HLSError ()

/**
 * We do not use the NSError userInfo dictionary since it is set at NSError creation time and cannot be updated afterwards.
 * Instead, we use our own internal dictionary
 */
@property (nonatomic, retain) NSDictionary *internalUserInfo;

@end

@implementation HLSError

#pragma mark Class methods

+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code
{
    return [[[[self class] alloc] initWithDomain:domain code:code] autorelease];
}

+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code localizedDescription:(NSString *)localizedDescription
{
    HLSError *error = [HLSError errorWithDomain:domain code:code];
    [error setLocalizedDescription:localizedDescription];
    return error;
}

#pragma mark Object creation and destruction

- (id)initWithDomain:(NSString *)domain code:(NSInteger)code
{
    if ((self = [super initWithDomain:domain code:code userInfo:nil /* not used */])) {
        self.internalUserInfo = [NSDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    self.internalUserInfo = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize internalUserInfo = m_internalUserInfo;

- (NSDictionary *)userInfo
{
    return self.internalUserInfo;
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
    if (! key) {
        HLSLoggerError(@"Missing key");
        return;
    }
    
    if (object) {
        self.internalUserInfo = [self.internalUserInfo dictionaryBySettingObject:object forKey:key];
    }
    else {
        self.internalUserInfo = [self.internalUserInfo dictionaryByRemovingObjectForKey:key];
    }
}

#pragma mark NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone
{
    // Unlike a conventional NSError, the userInfo dictionary is here mutable. A deep copy must therefore be made
    HLSError *errorCopy = [super copyWithZone:zone];
    errorCopy.internalUserInfo = [NSMutableDictionary dictionaryWithDictionary:self.internalUserInfo];
    return errorCopy;
}

@end
