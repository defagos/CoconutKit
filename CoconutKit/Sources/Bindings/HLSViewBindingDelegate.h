//
//  HLSViewBindingDelegate.h
//  CoconutKit
//
//  Created by Samuel Défago on 01/04/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

/**
 * Protocol implemented by object which want to be notified about binding events
 */
@protocol HLSViewBindingDelegate <NSObject>

@optional

// Only received if a transformation was performed
- (void)boundView:(UIView *)boundView transformationDidSucceedWithObject:(id)object;
- (void)boundView:(UIView *)boundView transformationDidFailWithObject:(id)object error:(NSError *)error;

- (void)boundView:(UIView *)boundView checkDidSucceedWithObject:(id)object;
- (void)boundView:(UIView *)boundView checkDidFailWithObject:(id)object error:(NSError *)error;

- (void)boundView:(UIView *)boundView updateDidSucceedWithObject:(id)object;
- (void)boundView:(UIView *)boundView updateDidFailWithObject:(id)object error:(NSError *)error;

@end
