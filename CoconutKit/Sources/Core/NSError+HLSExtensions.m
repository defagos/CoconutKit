//
//  NSError+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 27.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "NSError+HLSExtensions.h"

#import "HLSLogger.h"

@implementation NSError (HLSExtensions)

#pragma mark Accessors and mutators

- (NSError *)underlyingError
{
    return [self objectForKey:NSUnderlyingErrorKey];
}

- (NSArray *)errors
{
    // At most one error can be stored in an NSError using the standard NSUnderlyingErrorKey key
    NSError *error = [[self userInfo] objectForKey:NSUnderlyingErrorKey];
    if (error) {
        return [NSArray arrayWithObject:error];
    }
    else {
        return nil;
    }
}

- (id)objectForKey:(NSString *)key
{
    if (! key) {
        HLSLoggerError(@"Missing key");
        return nil;
    }
    
    return [[self userInfo] objectForKey:key];
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

#pragma mark Comparison

- (BOOL)hasCode:(NSInteger)code withinDomain:(NSString *)domain
{
    return [self code] == code && [[self domain] isEqualToString:domain];
}

@end
