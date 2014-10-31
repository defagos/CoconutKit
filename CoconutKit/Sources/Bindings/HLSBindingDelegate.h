//
//  HLSBindingDelegate.h
//  CoconutKit
//
//  Created by Samuel Défago on 01/04/14.
//  Copyright (c) 2014 Hortis. All rights reserved.
//

/**
 * Protocol implemented by object which want to be notified about binding events
 */
@protocol HLSBindingDelegate <NSObject>

@optional
- (void)view:(UIView *)view checkDidSucceedForObject:(id)object keyPath:(NSString *)keyPath;
- (void)view:(UIView *)view checkDidFailForObject:(id)object keyPath:(NSString *)keyPath withError:(NSError *)error;

- (void)view:(UIView *)view updateDidSucceedForObject:(id)object keyPath:(NSString *)keyPath;
- (void)view:(UIView *)view updateDidFailForObject:(id)object keyPath:(NSString *)keyPath withError:(NSError *)error;

@end
