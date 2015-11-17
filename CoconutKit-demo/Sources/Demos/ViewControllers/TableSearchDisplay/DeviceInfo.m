//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "DeviceInfo.h"

@interface DeviceInfo ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic) DeviceType type;

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
    NSParameterAssert(name);
    
    if (self = [super init]) {
        self.name = name;
        self.type = type;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
