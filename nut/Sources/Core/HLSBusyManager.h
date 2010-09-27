//
//  HLSBusyManager.h
//  nut
//
//  Created by Samuel Défago on 9/27/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSBusy.h"

/**
 * Class for managing the state of an object implementing the HLSBusy protocol.
 *
 * Designated initializer: init
 */
@interface HLSBusyManager : NSObject {
@private
    NSInteger m_busyCount;
    id<HLSBusy> m_managedObject;
}

@property (nonatomic, assign) id<HLSBusy> managedObject;

/**
 * Declare the managed object as busy / not busy
 */
- (void)increaseBusyCount;
- (void)decreaseBusyCount;

/**
 * Update the mode of the managed object to reflect the status of the manager
 */
- (void)updateManagedObjectMode;

@end
