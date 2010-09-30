//
//  HLSSingleBusyObjectManager.m
//  nut
//
//  Created by Samuel Défago on 9/27/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSSingleBusyObjectManager.h"

#import "HLSBusy.h"
#import "HLSLogger.h"

@interface HLSSingleBusyObjectManager ()

@property (nonatomic, retain) id<HLSBusy> managedObject;

@end

@implementation HLSSingleBusyObjectManager

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        m_busyCount = 0;
    }
    return self;
}

- (void)dealloc
{
    // TODO: In managedObject setter, update weak references of all managed object to nil. This way, it is safe
    //       to remove the manager before the views if manages. Maybe better: logger_debug when managedObject
    //       is not empty when a manager is destroyed (can lead to crashes!!)
    self.managedObject = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize managedObject = m_managedObject;

#pragma mark Interacting with the managed object

- (void)increaseBusyCount
{
    ++m_busyCount;
    [self updateObject:self.managedObject];
}

- (void)decreaseBusyCount
{
    --m_busyCount;
    if (m_busyCount < 0) {
        logger_debug(@"Was not busy");
        m_busyCount = 0;
    }
    [self updateObject:self.managedObject];
}

#pragma mark HLSBusyManager protocol implementation

- (void)registerObject:(id<HLSBusy>)object
{
    self.managedObject = object;
    [self updateObject:self.managedObject];
}

- (void)unregisterObject:(id<HLSBusy>)object
{
    if (self.managedObject == object) {
        self.managedObject = nil;
    }
}

- (void)updateObject:(id<HLSBusy>)managedObject
{
    if (m_busyCount == 1) {
        [managedObject enterBusyMode];
    }
    else if (m_busyCount == 0) {
        [managedObject exitBusyMode];
    }
}

@end
