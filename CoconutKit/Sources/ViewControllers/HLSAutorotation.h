//
//  HLSAutorotation.h
//  CoconutKit
//
//  Created by Samuel Défago on 10/16/12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

/**
 * Define the several ways for a container view controller to behave when interface rotation occurs. This means:
 *   - which view controllers decide whether rotation can occur or not
 *   - which view controllers receive rotation events (for children, this always occur from the topmost to the bottommost
 *     view controller, if they are involved)
 */
typedef NS_ENUM(NSInteger, HLSAutorotationMode) {
    HLSAutorotationModeEnumBegin = 0,
    HLSAutorotationModeContainer = HLSAutorotationModeEnumBegin,            // Default: The container implementation decides which view controllers are involved
                                                                            // and which ones receive events (for UIKit containers this might vary between iOS
                                                                            // versions)
    HLSAutorotationModeContainerAndNoChildren,                              // The container only decides and receives events
    HLSAutorotationModeContainerAndTopChildren,                             // The container and its top children decide and receive events. A container might have
                                                                            // several top children if it displays several view controllers next to each other
    HLSAutorotationModeContainerAndAllChildren,                             // The container and all its children (even those not visible) decide and receive events
    HLSAutorotationModeEnumEnd,
    HLSAutorotationModeEnumSize = HLSAutorotationModeEnumEnd - HLSAutorotationModeEnumBegin
};
