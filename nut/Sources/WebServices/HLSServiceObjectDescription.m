//
//  HLSServiceObjectDescription.m
//  nut
//
//  Created by Samuel Défago on 7/31/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSServiceObjectDescription.h"

@interface HLSServiceObjectDescription ()

@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *id;
@property (nonatomic, retain) NSDictionary *fields;

@end

@implementation HLSServiceObjectDescription

#pragma mark Object creation and destruction

- (id)initWithClassName:(NSString *)className id:(NSString *)id fields:(NSDictionary *)fields
{
    if (self = [super init]) {
        self.className = className;
        self.id = id;
        self.fields = fields;
    }
    return self;
}

- (void)dealloc
{
    self.className = nil;
    self.id = nil;
    self.fields = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize className = m_className;

@synthesize id = m_id;

@synthesize fields = m_fields;

@end
