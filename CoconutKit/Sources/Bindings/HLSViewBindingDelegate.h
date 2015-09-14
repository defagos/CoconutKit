//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * Protocol to be implemented by classes whose instances want to show interest in receiving binding events. Information 
 * about the binding arameters can be obtained by accessing the bindingInformation property of the boundView parameter
 */
@protocol HLSViewBindingDelegate <NSObject>

@optional

/**
 * Transformation events. Only received when a transformation is actually required
 */
- (void)boundView:(UIView *)boundView transformationDidSucceedWithObject:(id)object;
- (void)boundView:(UIView *)boundView transformationDidFailWithObject:(id)object error:(NSError *)error;

/**
 * Model check events
 */
- (void)boundView:(UIView *)boundView checkDidSucceedWithObject:(id)object;
- (void)boundView:(UIView *)boundView checkDidFailWithObject:(id)object error:(NSError *)error;

/**
 * Model update events
 */
- (void)boundView:(UIView *)boundView updateDidSucceedWithObject:(id)object;
- (void)boundView:(UIView *)boundView updateDidFailWithObject:(id)object error:(NSError *)error;

@end
