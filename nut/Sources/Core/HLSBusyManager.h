//
//  HLSBusyManager.h
//  nut
//
//  Created by Samuel Défago on 9/30/10.
//  Copyright 2010 Hortis. All rights reserved.
//

// Forward declarations
@protocol HLSBusy;

/**
 * Protocol for implementing objects deciding whether an object oe objects they manage must be busy or not.
 */
@protocol HLSBusyManager <NSObject>

/**
 * The object to be managed can be registered at any time after manager creation. This way a process which can 
 * lead to a busy state (e.g. an HTTP request) can be initiated before the objects which must be managed 
 * (e.g. a view controller displaying the web page) are actually created.
 */
- (void)registerObject:(id<HLSBusy>)object;
- (void)unregisterObject:(id<HLSBusy>)object;

/**
 * This method is called when the "busy state" of a managed object managed needs to be updated. The manager usually
 * keeps some internal state variables which allow it to take appropriate action when this method is called (this 
 * means calling the right HLSBusy protocol methods)
 */
- (void)updateObject:(id<HLSBusy>)managedObject;

@end
