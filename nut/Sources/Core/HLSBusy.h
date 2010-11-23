//
//  HLSBusy.h
//  nut
//
//  Created by Samuel Défago on 9/22/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSBusyManager.h"

// TODO: This class design is not optimal (except for the enter / exitBusyMode methods which are a good idea). Completely
//       rewrite it to avoid cyclic references with HLSBusyManager (and to avoid subtle issues when writing dealloc methods
//       with busy managers)

/**
 * Protocol for objects to implement their "I'm busy" - "I'm not busy" behaviors.
 */
@protocol HLSBusy <NSObject>

- (void)enterBusyMode;
- (void)exitBusyMode;

/*
 * A busy manager must always have a lifetime including or equal to the lifetime of the object(s) it manages
 * (otherwise they would leave HLSBusy objects unmanaged, leading to undefined behavior). A weak reference
 * therefore always suffices (and this does break cyclic reference counts if managers happen to retain the
 * HLSBusy objects they manage, which is quite likely)
 */
@property (nonatomic, assign) id<HLSBusyManager> busyManager;

@end

/**
 * The property is always created in the same way. We cannot force users to derive from a common class
 * which would have implemented this code, so we use a macro to generate it easily instead
 */
#define SYNTHESIZE_BUSY_MANAGER()                               \
                                                                \
@synthesize busyManager = m_busyManager;                        \
                                                                \
- (void)setBusyManager:(id<HLSBusyManager>)busyManager          \
{                                                               \
    if (m_busyManager == busyManager) {                         \
        return;                                                 \
    }                                                           \
                                                                \
    if (m_busyManager) {                                        \
        [m_busyManager unregisterObject:self];                  \
    }                                                           \
                                                                \
    m_busyManager = busyManager;                                \
                                                                \
    if (m_busyManager) {                                        \
        [m_busyManager registerObject:self];                    \
    }                                                           \
}

/**
 * Use this macro in an object implementing the HLSBusy protocol in order to ask its manager
 * for refresh. A typical example is in the implementation of the viewWillAppear: method
 * of a view controller implementing HLSBusy
 */
#define BUSY_MANAGER_ASK_FOR_UPDATE()                   \
    if (self.busyManager) {                             \
        [self.busyManager updateObject:self];           \
    }                                                   \
    else {                                              \
        [self exitBusyMode];                            \
    }
