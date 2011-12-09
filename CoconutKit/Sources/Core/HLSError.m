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

- (NSString *)localizedDescription
{
    return [self objectForKey:NSLocalizedDescriptionKey];
}

- (void)setLocalizedDescription:(NSString *)localizedDescription
{
    [self setObject:localizedDescription forKey:NSLocalizedDescriptionKey];
}

- (NSString *)localizedFailureReason
{
    return [self objectForKey:NSLocalizedFailureReasonErrorKey];
}

- (void)setLocalizedFailureReason:(NSString *)localizedFailureReason
{
    [self setObject:localizedFailureReason forKey:NSLocalizedFailureReasonErrorKey];
}

- (NSString *)localizedRecoverySuggestion
{
    return [self objectForKey:NSLocalizedRecoverySuggestionErrorKey];
}

- (void)setLocalizedRecoverySuggestion:(NSString *)localizedRecoverySuggestion
{
    [self setObject:localizedRecoverySuggestion forKey:NSLocalizedRecoverySuggestionErrorKey];
}

- (NSArray *)localizedRecoveryOptions
{
    return [self objectForKey:NSLocalizedRecoveryOptionsErrorKey];
}

- (void)setLocalizedRecoveryOptions:(NSArray *)localizedRecoveryOptions
{
    HLSAssertObjectsInEnumerationAreKindOfClass(localizedRecoveryOptions, NSString);
    
    [self setObject:localizedRecoveryOptions forKey:NSLocalizedRecoveryOptionsErrorKey];
}

- (id)recoveryAttempter
{
    return [self objectForKey:NSRecoveryAttempterErrorKey];
}

- (void)setRecoveryAttempter:(id)recoveryAttempter
{
    [self setObject:recoveryAttempter forKey:NSRecoveryAttempterErrorKey];
}

- (NSString *)helpAnchor
{
    return [self objectForKey:NSHelpAnchorErrorKey];
}

- (void)setHelpAnchor:(NSString *)helpAnchor
{
    [self setObject:helpAnchor forKey:NSHelpAnchorErrorKey];
}

- (NSError *)underlyingError
{
    return [self objectForKey:NSUnderlyingErrorKey];
}

- (void)setUnderlyingError:(NSError *)underlyingError
{
    [self setObject:underlyingError forKey:NSUnderlyingErrorKey];
}

- (id)objectForKey:(NSString *)key
{
    if (! key) {
        HLSLoggerError(@"Missing key");
        return nil;
    }
    
    return [self.internalUserInfo objectForKey:key];
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

#pragma mark Accessing custom information

- (NSDictionary *)customUserInfo
{
    NSMutableDictionary *customUserInfo = [NSMutableDictionary dictionaryWithDictionary:self.internalUserInfo];
    [customUserInfo removeObjectForKey:NSLocalizedDescriptionKey];
    [customUserInfo removeObjectForKey:NSLocalizedFailureReasonErrorKey];
    [customUserInfo removeObjectForKey:NSLocalizedRecoverySuggestionErrorKey];
    [customUserInfo removeObjectForKey:NSLocalizedRecoveryOptionsErrorKey];
    [customUserInfo removeObjectForKey:NSRecoveryAttempterErrorKey];
    [customUserInfo removeObjectForKey:NSHelpAnchorErrorKey];
    [customUserInfo removeObjectForKey:NSUnderlyingErrorKey];
    return [NSDictionary dictionaryWithDictionary:customUserInfo];
}
             
- (BOOL)isEqualToError:(HLSError *)error
{
    return [[self domain] isEqualToString:[error domain]] && [self code] == [error code];
}

@end
