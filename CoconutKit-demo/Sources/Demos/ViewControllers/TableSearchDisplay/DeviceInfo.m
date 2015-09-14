//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "DeviceInfo.h"

@interface DeviceInfo ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) DeviceType type;

@end

@implementation DeviceInfo

#pragma mark Class methods

+ (DeviceInfo *)deviceInfoWithName:(NSString *)name type:(DeviceType)type
{
    return [[[self class] alloc] initWithName:name type:type];
}

#pragma mark Object creation and destruction

- (instancetype)initWithName:(NSString *)name type:(DeviceType)type
{
    if (self = [super init]) {
        self.name = name;
        self.type = type;
    }
    return self;
}

@end
