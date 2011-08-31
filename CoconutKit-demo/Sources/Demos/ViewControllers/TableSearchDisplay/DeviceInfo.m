//
//  DeviceInfo.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/14/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "DeviceInfo.h"

@interface DeviceInfo ()

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) DeviceType type;

@end

@implementation DeviceInfo

#pragma mark Class methods

+ (DeviceInfo *)deviceInfoWithName:(NSString *)name type:(DeviceType)type
{
    return [[[[self class] alloc] initWithName:name type:type] autorelease];
}

#pragma mark Object creation and destruction

- (id)initWithName:(NSString *)name type:(DeviceType)type
{
    if ((self = [super init])) {
        self.name = name;
        self.type = type;
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
    self.name = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize name = m_name;

@synthesize type = m_type;

@end
