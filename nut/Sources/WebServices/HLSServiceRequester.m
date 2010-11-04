//
//  HLSServiceRequester.m
//  nut
//
//  Created by Samuel Défago on 7/30/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSServiceRequester.h"

#import "HLSRuntimeChecks.h"

@interface HLSServiceRequester ()

@property (nonatomic, retain) NSString *requestId;

@end

@implementation HLSServiceRequester

#pragma mark Object creation and destruction

- (id)initWithRequest:(HLSServiceRequest *)request settings:(HLSServiceSettings *)settings;
{
    if (self = [super init]) {
        self.requestId = request.id;
    }
    return self;
}

- (id)init
{
    FORBIDDEN_INHERITED_METHOD();
    return nil;
}

- (void)dealloc
{
    self.delegate = nil;
    self.requestId = nil;
    [super dealloc];
}

#pragma mark Accesors and mutators

@synthesize delegate = m_delegate;

@synthesize requestId = m_requestId;

@end
