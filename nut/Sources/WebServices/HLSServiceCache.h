//
//  HLSServiceCache.h
//  nut
//
//  Created by Samuel Défago on 7/29/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Designated initializer: init
 */
@interface HLSServiceCache : NSObject {
@private
    NSMutableDictionary *m_classNameToIdMap;         // class name as key, pointing at a dictionary mapping ids to objects of that class
}

- (id)objectWithClassName:(NSString *)className id:(NSString *)id;
- (NSArray *)objectsWithClassName:(NSString *)className;

// TODO: Maybe className not needed explicitly (use introspection)
- (void)setObject:(id)object forClassName:(NSString *)className andId:(NSString *)id;

@end
