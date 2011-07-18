//
//  HLSError.m
//  nut
//
//  Created by Samuel Défago on 04.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSError.h"

#import "HLSAssert.h"
#import "HLSErrorTemplate.h"
#import "HLSLogger.h"
#import "NSDictionary+HLSExtensions.h"

@interface HLSError ()

+ (BOOL)registerErrorTemplate:(HLSErrorTemplate *)errorTemplate forIdentifier:(NSString *)identifier;
+ (HLSErrorTemplate *)errorTemplateForIdentifier:(NSString *)identifier;

- (id)initFromIdentifier:(NSString *)identifier nestedError:(NSError *)nestedError userInfo:(NSDictionary *)userInfo;

@end

static NSMutableDictionary *s_identifierToErrorTemplateMap = nil;

@implementation HLSError

#pragma mark Class methods

+ (BOOL)registerDefaultCode:(NSInteger)code
                     domain:(NSString *)domain 
       localizedDescription:(NSString *)localizedDescription 
     localizedFailureReason:(NSString *)localizedFailureReason
localizedRecoverySuggestion:(NSString *)localizedRecoverySuggestion
   localizedRecoveryOptions:(NSArray *)localizedRecoveryOptions
          recoveryAttempter:(id)recoveryAttempter
                 helpAnchor:(NSString *)helpAnchor
              forIdentifier:(NSString *)identifier
{
    HLSErrorTemplate *errorTemplate = [[[HLSErrorTemplate alloc] initWithCode:code domain:domain] autorelease];
    errorTemplate.localizedDescription = localizedDescription;
    errorTemplate.localizedFailureReason = localizedFailureReason;
    errorTemplate.localizedRecoverySuggestion = localizedRecoverySuggestion;
    errorTemplate.localizedRecoveryOptions = localizedRecoveryOptions;
    errorTemplate.recoveryAttempter = recoveryAttempter;
    errorTemplate.helpAnchor = helpAnchor;
    
    return [self registerErrorTemplate:errorTemplate forIdentifier:identifier];
}

+ (BOOL)registerDefaultCode:(NSInteger)code
                     domain:(NSString *)domain 
       localizedDescription:(NSString *)localizedDescription
              forIdentifier:(NSString *)identifier
{
    return [self registerDefaultCode:code
                              domain:domain
                localizedDescription:localizedDescription
              localizedFailureReason:nil 
         localizedRecoverySuggestion:nil 
            localizedRecoveryOptions:nil
                   recoveryAttempter:nil
                          helpAnchor:nil 
                       forIdentifier:identifier];
}

+ (id)errorFromIdentifier:(NSString *)identifier nestedError:(NSError *)nestedError userInfo:(NSDictionary *)userInfo
{
    return [[[[self class] alloc] initFromIdentifier:identifier nestedError:nestedError userInfo:userInfo] autorelease];
}

+ (id)errorFromIdentifier:(NSString *)identifier nestedError:(NSError *)nestedError
{
    return [[[[self class] alloc] initFromIdentifier:identifier nestedError:nestedError userInfo:nil] autorelease];
}

+ (id)errorFromIdentifier:(NSString *)identifier userInfo:(NSDictionary *)userInfo
{
    return [[[[self class] alloc] initFromIdentifier:identifier nestedError:nil userInfo:userInfo] autorelease];
}

+ (id)errorFromIdentifier:(NSString *)identifier
{
    return [[[[self class] alloc] initFromIdentifier:identifier nestedError:nil userInfo:nil] autorelease];
}

+ (BOOL)registerErrorTemplate:(HLSErrorTemplate *)errorTemplate forIdentifier:(NSString *)identifier
{
    @synchronized(self) {
        // Create the identifier to template map lazily
        if (! s_identifierToErrorTemplateMap) {
            s_identifierToErrorTemplateMap = [[NSMutableDictionary dictionary] retain];
        }
        
        // Check that no template has already been associated with the identifier
        HLSErrorTemplate *existingErrorTemplate = [s_identifierToErrorTemplateMap objectForKey:identifier];
        if (existingErrorTemplate) {
            HLSLoggerError(@"An error template %@ has already been registered for identifier %@", existingErrorTemplate, identifier);
            return NO;
        }
        
        // Add the new template
        [s_identifierToErrorTemplateMap setObject:errorTemplate forKey:identifier];
        return YES;
    }
}

+ (HLSErrorTemplate *)errorTemplateForIdentifier:(NSString *)identifier
{
    @synchronized(self) {
        return [s_identifierToErrorTemplateMap objectForKey:identifier];
    }
}

#pragma mark Object creation and destruction

- (id)initFromIdentifier:(NSString *)identifier nestedError:(NSError *)nestedError userInfo:(NSDictionary *)userInfo
{
    // Locate the error template
    HLSErrorTemplate *errorTemplate = [HLSError errorTemplateForIdentifier:identifier];
    if (! errorTemplate) {
        HLSLoggerError(@"The error identifier %@ has not been registered", identifier);
        [self release];
        return nil;
    }
    
    // Build the full user info dictionary. Start with the information provided by the caller
    NSMutableDictionary *fullUserInfo = nil;
    if (userInfo) {
        fullUserInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    }
    else {
        fullUserInfo = [NSMutableDictionary dictionary];
    }
    
    // Localized description
    if ([fullUserInfo objectForKey:NSLocalizedDescriptionKey]) {
        HLSLoggerWarn(@"userInfo already contains key %@; will be overwritten", NSLocalizedDescriptionKey);
        [fullUserInfo removeObjectForKey:NSLocalizedDescriptionKey];
    }
    [fullUserInfo safelySetObject:errorTemplate.localizedDescription forKey:NSLocalizedDescriptionKey];
    
    // Localized failure reason
    if ([fullUserInfo objectForKey:NSLocalizedFailureReasonErrorKey]) {
        HLSLoggerWarn(@"userInfo already contains key %@; will be overwritten", NSLocalizedFailureReasonErrorKey);
        [fullUserInfo removeObjectForKey:NSLocalizedFailureReasonErrorKey];
    }
    [fullUserInfo safelySetObject:errorTemplate.localizedFailureReason forKey:NSLocalizedFailureReasonErrorKey];

    // Localized recovery suggestion
    if ([fullUserInfo objectForKey:NSLocalizedRecoverySuggestionErrorKey]) {
        HLSLoggerWarn(@"userInfo already contains key %@; will be overwritten", NSLocalizedRecoverySuggestionErrorKey);
        [fullUserInfo removeObjectForKey:NSLocalizedRecoverySuggestionErrorKey];
    }
    [fullUserInfo safelySetObject:errorTemplate.localizedRecoverySuggestion forKey:NSLocalizedRecoverySuggestionErrorKey];
    
    // Localized recovery options
    if ([fullUserInfo objectForKey:NSLocalizedRecoveryOptionsErrorKey]) {
        HLSLoggerWarn(@"userInfo already contains key %@; will be overwritten", NSLocalizedRecoveryOptionsErrorKey);
        [fullUserInfo removeObjectForKey:NSLocalizedRecoveryOptionsErrorKey];
    }
    [fullUserInfo safelySetObject:errorTemplate.localizedRecoveryOptions forKey:NSLocalizedRecoveryOptionsErrorKey];
    
    // Recovery attempter
    if ([fullUserInfo objectForKey:NSRecoveryAttempterErrorKey]) {
        HLSLoggerWarn(@"userInfo already contains key %@; will be overwritten", NSRecoveryAttempterErrorKey);
        [fullUserInfo removeObjectForKey:NSRecoveryAttempterErrorKey];
    }
    [fullUserInfo safelySetObject:errorTemplate.recoveryAttempter forKey:NSRecoveryAttempterErrorKey];

    // Help anchor
    if ([fullUserInfo objectForKey:NSHelpAnchorErrorKey]) {
        HLSLoggerWarn(@"userInfo already contains key %@; will be overwritten", NSHelpAnchorErrorKey);
        [fullUserInfo removeObjectForKey:NSHelpAnchorErrorKey];
    }
    [fullUserInfo safelySetObject:errorTemplate.helpAnchor forKey:NSHelpAnchorErrorKey];
    
    // Nested error
    if ([fullUserInfo objectForKey:NSUnderlyingErrorKey]) {
        HLSLoggerWarn(@"userInfo already contains key %@; will be overwritten", NSUnderlyingErrorKey);
        [fullUserInfo removeObjectForKey:NSUnderlyingErrorKey];
    }
    [fullUserInfo safelySetObject:nestedError forKey:NSUnderlyingErrorKey];
    
    if ((self = [super initWithDomain:errorTemplate.domain 
                                 code:errorTemplate.code 
                             userInfo:[NSDictionary dictionaryWithDictionary:fullUserInfo]])) {
        
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

#pragma mark Accessors and mutators

- (NSError *)nestedError
{
    return [[self userInfo] objectForKey:NSUnderlyingErrorKey];
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

@end
