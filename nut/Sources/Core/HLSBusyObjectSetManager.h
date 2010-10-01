//
//  HLSBusyObjectSetManager.h
//  nut
//
//  Created by Samuel Défago on 9/27/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSBusyManager.h"

/**
 * Standard class for managing the state of a set of objects implementing the HLSBusy protocol. This simple implementation
 * of the HLSBusyManager protocol should meet most needs when many objects need to be set to busy / not busy according
 * simultaneously.
 *
 * The lifetime of the managed objects must be included or equal to the lifetime of the manager object
 *
 * Designated initializer: init
 */
@interface HLSBusyObjectSetManager : NSObject <HLSBusyManager> {
@private
    NSInteger m_busyCount;
    NSMutableSet *m_managedObjects;          // contains id<HLSBusy> objects
}

/**
 * Make all managed objects more or less busy
 */
- (void)increaseBusyCount;
- (void)decreaseBusyCount;

@end
