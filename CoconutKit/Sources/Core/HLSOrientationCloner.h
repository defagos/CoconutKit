//
//  HLSOrientationCloner.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/3/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * There are two kinds of orientable view controllers:
 * 1) View controllers which can autoresize: Such view controllers manage their orientation themselves. To get this
 *    behavior the view controller must return the orientations it supports by implementing shouldAutorotateToInterfaceOrientation:,
 *    and all its subviews must have their autoresizing flags properly set (usually flexible width and height, and
 *    fixed margins). Such view controllers do not need to implement the HLSOrientationCloner protocol.
 * 2) View controllers which cannot resize properly, or which require a different layout depending on the device
 *    orientation. In such cases, since a xib loaded by a view controller cannot be changed at runtime, a new view
 *    controller clone with the proper orientation is needed when the device is rotated. In order to be able to
 *    implement container view controllers, it was required to have a common language for generating clones for orientations. 
 *    This is just the purpose of the HLSOrientationCloner protocol.
 */
@protocol HLSOrientationCloner <NSObject>

/**
 * Your implementation must return a clone of the view controller with the proper orientation, or nil if the orientation
 * is not supported. Note that UIInterfaceOrientation is the parameter, not UIDeviceOrientation (this is because we need
 * to know if the interface is in landscape or portrait mode; the device can also be in flat positions which are
 * irrelevant in our case)
 */
- (UIViewController *)viewControllerCloneWithOrientation:(UIInterfaceOrientation)orientation;

@end
