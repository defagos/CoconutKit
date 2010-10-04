//
//  HLSReloadable.h
//  nut
//
//  Created by Samuel Défago on 8/7/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Protocol for objects whose data can be reloaded
 */
@protocol HLSReloadable <NSObject>

- (void)reloadData;

// TODO: Enrich with interface for implementing behavior when reloading data. This way (e.g.) an object managing
//       a data source can put a view controllr in "loading mode" (as defined by the HLSReloadable view controller
//       by implementing this protocl) and then in "loaded mode"

@end
