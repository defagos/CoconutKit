//
//  DeviceInfo.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/14/11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

typedef NS_ENUM(NSInteger, DeviceType) {
    DeviceTypeEnumBegin = 0,
    DeviceTypeAll = DeviceTypeEnumBegin,
    DeviceTypeMusicPlayer,
    DeviceTypePhone,
    DeviceTypeTablet,
    DeviceTypeEnumEnd,
    DeviceTypeEnumSize = DeviceTypeEnumEnd - DeviceTypeEnumBegin
};

@interface DeviceInfo : NSObject

+ (DeviceInfo *)deviceInfoWithName:(NSString *)name type:(DeviceType)type;

- (id)initWithName:(NSString *)name type:(DeviceType)type;

@property (nonatomic, readonly, strong) NSString *name;
@property (nonatomic, readonly, assign) DeviceType type;

@end
