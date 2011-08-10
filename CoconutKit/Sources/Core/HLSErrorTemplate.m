//
//  HLSErrorTemplate.m
//  CoconutKit
//
//  Created by Samuel Défago on 04.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSErrorTemplate.h"

#import "HLSAssert.h"
#import "HLSLogger.h"

@interface HLSErrorTemplate ()

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, retain) NSString *domain;

@end

@implementation HLSErrorTemplate

#pragma mark Object creation and destruction

- (id)initWithCode:(NSInteger)code domain:(NSString *)domain
{
    if ((self = [super init])) {
        if ([domain length] == 0) {
            HLSLoggerError(@"An error domain is mandatory");
            [self release];
            return nil;
        }
        
        self.code = code;
        self.domain = domain;
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

- (void)dealloc
{
    self.domain = nil;
    self.localizedDescription = nil;
    self.localizedFailureReason = nil;
    self.localizedRecoverySuggestion = nil;
    self.localizedRecoveryOptions = nil;
    self.recoveryAttempter = nil;
    self.helpAnchor = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize code = m_code;

@synthesize domain = m_domain;

@synthesize localizedDescription = m_localizedDescription;

@synthesize localizedFailureReason = m_localizedFailureReason;

@synthesize localizedRecoverySuggestion = m_localizedRecoverySuggestion;

@synthesize localizedRecoveryOptions = m_localizedRecoveryOptions;

@synthesize recoveryAttempter = m_recoveryAttempter;

@synthesize helpAnchor = m_helpAnchor;

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; code: %d; domain: %@; localizedDescription: %@; "
            "localizedFailureReason: %@; localizedRecoverySuggestion: %@; localizedRecoveryOptions: %@; "
            "recoveryAttempter: %@; helpAnchor: %@>", 
            [self class],
            self,
            self.code,
            self.domain,
            self.localizedDescription,
            self.localizedFailureReason,
            self.localizedRecoverySuggestion,
            self.localizedRecoveryOptions,
            self.recoveryAttempter,
            self.helpAnchor];
}

@end
