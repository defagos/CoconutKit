//
//  HLSBusy.h
//  nut
//
//  Created by Samuel Défago on 9/22/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Protocol for objects to implement their "I'm busy" - "I'm not busy" behaviors.
 */
@protocol HLSBusy <NSObject>
// TODO: optional

- (void)enterBusyMode;
- (void)exitBusyMode;

@end
