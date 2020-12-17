//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSBindingContext.h"

@import Foundation;
@import UIKit;

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
- (void)boundView:(__kindof UIView *)boundView transformationDidSucceedWithContext:(HLSBindingContext *)context;
- (void)boundView:(__kindof UIView *)boundView transformationDidFailWithContext:(HLSBindingContext *)context error:(NSError *)error;

/**
 * Model check events
 */
- (void)boundView:(__kindof UIView *)boundView checkDidSucceedWithContext:(HLSBindingContext *)context;
- (void)boundView:(__kindof UIView *)boundView checkDidFailWithContext:(HLSBindingContext *)context error:(NSError *)error;

/**
 * Model update events
 */
- (void)boundView:(__kindof UIView *)boundView updateDidSucceedWithContext:(HLSBindingContext *)context;
- (void)boundView:(__kindof UIView *)boundView updateDidFailWithContext:(HLSBindingContext *)context error:(NSError *)error;

@end
NS_ASSUME_NONNULL_END
