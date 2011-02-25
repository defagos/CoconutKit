//
//  HLSServiceObject.m
//  nut
//
//  Created by Samuel Défago on 8/6/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSServiceObject.h"

#import "HLSRuntimeChecks.h"

@interface HLSServiceObject ()

@property (nonatomic, retain) NSString *id;

@end

@implementation HLSServiceObject

#pragma mark Object creation and destruction

- (id)initWithId:(NSString *)id
{
    if ((self = [super init])) {
        self.id = id;
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
    self.id = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize id = m_id;

@end
