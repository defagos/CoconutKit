//
//  DeviceInfo.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/14/11.
//  Copyright 2011 Hortis. All rights reserved.
//

typedef enum {
    DeviceTypeEnumBegin = 0,
    DeviceTypeAll = DeviceTypeEnumBegin,
    DeviceTypeMusicPlayer,
    DeviceTypePhone,
    DeviceTypeTablet,
    DeviceTypeEnumEnd,
    DeviceTypeEnumSize = DeviceTypeEnumEnd - DeviceTypeEnumBegin
} DeviceType;

@interface DeviceInfo : NSObject {
@private
    NSString *m_name;
    DeviceType m_type;
}

+ (DeviceInfo *)deviceInfoWithName:(NSString *)name type:(DeviceType)type;

- (id)initWithName:(NSString *)name type:(DeviceType)type;

@property (nonatomic, readonly, retain) NSString *name;
@property (nonatomic, readonly, assign) DeviceType type;

@end
