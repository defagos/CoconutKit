//
//  HLSBusyObjectSetManager.m
//  nut
//
//  Created by Samuel Défago on 9/27/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSBusyObjectSetManager.h"

#import "HLSBusy.h"
#import "HLSLogger.h"

@interface HLSBusyObjectSetManager ()

@property (nonatomic, retain) NSMutableSet *managedObjects;

@end

@implementation HLSBusyObjectSetManager

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        self.managedObjects = [NSMutableSet set];
        m_busyCount = 0;
    }
    return self;
}

- (void)dealloc
{
    // TODO: In managedObjects setter, update weak references of all managed objects to nil. This way, it is safe
    //       to remove the manager before the objects if manages. Maybe better: also logger_debug when managedObject
    //       is not empty when a manager is destroyed, because this should not happen
    self.managedObjects = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize managedObjects = m_managedObjects;

#pragma mark Interacting with the managed object

- (void)increaseBusyCount
{
    ++m_busyCount;
    logger_debug(@"Busy counter: %d", m_busyCount);
    for (id<HLSBusy> object in self.managedObjects) {
        [self updateObject:object];   
    }
}

- (void)decreaseBusyCount
{
    --m_busyCount;
    if (m_busyCount < 0) {
        logger_debug(@"Was not busy");
        m_busyCount = 0;
    }
    logger_debug(@"Busy counter: %d", m_busyCount);
    for (id<HLSBusy> object in self.managedObjects) {
        [self updateObject:object];   
    }
}

#pragma mark HLSBusyManager protocol implementation

- (void)registerObject:(id<HLSBusy>)object
{
    [self.managedObjects addObject:object];
    
    // Synchronize the object with the manager state
    [self updateObject:object];
}

- (void)unregisterObject:(id<HLSBusy>)object
{
    [self.managedObjects removeObject:object];
}

- (void)updateObject:(id<HLSBusy>)object
{
    if (! [self.managedObjects containsObject:object]) {
        logger_debug(@"Object not managed by the manager");
        return;
    }
    
    if (m_busyCount == 1) {
        [object enterBusyMode];
    }
    else if (m_busyCount == 0) {
        [object exitBusyMode];
    }
}

@end
