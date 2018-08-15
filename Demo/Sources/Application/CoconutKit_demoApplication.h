//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <CoconutKit/CoconutKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoconutKit_demoApplication : NSObject <
    HLSStackControllerDelegate,
    UINavigationControllerDelegate,
    UITabBarControllerDelegate
>

@property (nonatomic, readonly) __kindof UIViewController *rootViewController;

- (void)savePendingChanges;

@end

NS_ASSUME_NONNULL_END
