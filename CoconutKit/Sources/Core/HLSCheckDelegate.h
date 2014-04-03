//
//  HLSCheckDelegate.h
//  CoconutKit
//
//  Created by Samuel Défago on 01/04/14.
//  Copyright (c) 2014 Hortis. All rights reserved.
//

/**
 * Protocol implemented by object which want to be notified about checks
 */
@protocol HLSCheckDelegate <NSObject>

@optional

- (void)sender:(id)sender didCheckValue:(id)value forObject:(id)object keyPath:(NSString *)keyPath;

- (void)sender:(id)sender didFailCheckForValue:(id)value object:(id)object keyPath:(NSString *)keyPath withError:(NSError *)error;

@end
