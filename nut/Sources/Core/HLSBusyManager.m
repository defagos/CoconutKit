//
//  HLSBusyManager.m
//  nut
//
//  Created by Samuel Défago on 9/27/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSBusyManager.h"

#import "HLSLogger.h"

@implementation HLSBusyManager

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
    self.managedObject = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize managedObject = m_managedObject;

#pragma mark Interacting with the managed object

- (void)increaseBusyCount
{
    ++m_busyCount;
    [self updateManagedObjectMode];
}

- (void)decreaseBusyCount
{
    --m_busyCount;
    if (m_busyCount < 0) {
        logger_debug(@"Was not busy");
        m_busyCount = 0;
    }
    [self updateManagedObjectMode];
}

- (void)updateManagedObjectMode
{
    if (m_busyCount == 1) {
        [self.managedObject enterBusyMode];
    }
    else if (m_busyCount == 0) {
        [self.managedObject exitBusyMode];
    }
}

@end
