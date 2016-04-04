//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

NS_ASSUME_NONNULL_BEGIN

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

- (instancetype)initWithName:(NSString *)name type:(DeviceType)type NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly) DeviceType type;

@end

@interface DeviceInfo (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
