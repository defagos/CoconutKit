//
//  HLSServiceRequest.m
//  nut
//
//  Created by Samuel Défago on 7/30/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSServiceRequest.h"

@interface HLSServiceRequest ()

@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *body;

@end

@implementation HLSServiceRequest

#pragma mark Object creation and destruction

- (id)initWithBody:(NSString *)body
{
    // Ids are automatically assigned by this very basic id factory
    static NSUInteger s_idAsInteger = 1;
    if ((self = [super init])) {
        self.body = body;
        self.id = [NSString stringWithFormat:@"%d", s_idAsInteger];
        ++s_idAsInteger;
    }
    return self;
}

- (void)dealloc
{
    self.id = nil;
    self.body = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize id = m_id;

@synthesize body = m_body;

@end
