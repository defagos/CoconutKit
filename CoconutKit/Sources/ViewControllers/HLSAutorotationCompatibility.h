//
//  HLSAutorotationCompatibility.h
//  CoconutKit
//
//  Created by Samuel Défago on 10/16/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * This protocol exists to suppress warnings when compiling against the iOS 5 SDK
 *
 * TODO: Remove when CoconutKit compatible with iOS >= 6
 */
@protocol HLSAutorotationCompatibility <NSObject>

@optional

/**
 * Return whether autorotation should occur or not
 */
- (BOOL)shouldAutorotate;

/**
 * Returns all of the interface orientations that are supported
 */
- (NSUInteger)supportedInterfaceOrientations;

@end
