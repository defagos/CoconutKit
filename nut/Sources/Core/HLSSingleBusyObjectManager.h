//
//  HLSSingleBusyObjectManager.h
//  nut
//
//  Created by Samuel Défago on 9/27/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSBusyManager.h"

/**
 * Standard class for managing the state of an object implementing the HLSBusy protocol. This simple implementation
 * of the HLSBusyManager protocol should meet most needs when a single object needs to be managed.
 *
 * The lifetime of the managed object must be included or equal to the lifetime of the manager object
 *
 * Designated initializer: init
 */
@interface HLSSingleBusyObjectManager : NSObject <HLSBusyManager> {
@private
    NSInteger m_busyCount;
    id<HLSBusy> m_managedObject;
}

/**
 * Make the managed object more or less busy
 */
- (void)increaseBusyCount;
- (void)decreaseBusyCount;

@end
