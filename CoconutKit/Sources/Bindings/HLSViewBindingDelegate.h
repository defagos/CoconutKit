//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Protocol to be implemented by classes whose instances want to show interest in receiving binding events. Information 
 * about the binding parameters can be obtained by accessing the bindingInformation property of the boundView parameter
 */
@protocol HLSViewBindingDelegate <NSObject>

@optional

/**
 * Transformation events. Only received when a transformation is actually required
 */
- (void)boundView:(__kindof UIView *)boundView transformationDidSucceedWithObject:(id)object;
- (void)boundView:(__kindof UIView *)boundView transformationDidFailWithObject:(id)object error:(NSError *)error;

/**
 * Model check events
 */
- (void)boundView:(__kindof UIView *)boundView checkDidSucceedWithObject:(id)object;
- (void)boundView:(__kindof UIView *)boundView checkDidFailWithObject:(id)object error:(NSError *)error;

/**
 * Model update events
 */
- (void)boundView:(__kindof UIView *)boundView updateDidSucceedWithObject:(id)object;
- (void)boundView:(__kindof UIView *)boundView updateDidFailWithObject:(id)object error:(NSError *)error;

@end
NS_ASSUME_NONNULL_END
