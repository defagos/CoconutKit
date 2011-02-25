//
//  HLSServiceCache.m
//  nut
//
//  Created by Samuel Défago on 7/29/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSServiceCache.h"

@interface HLSServiceCache ()

@property (nonatomic, retain) NSMutableDictionary *classNameToIdMap;

@end

@implementation HLSServiceCache

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.classNameToIdMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    self.classNameToIdMap = nil;
    [super dealloc];
}

#pragma mark Accesors and mutators

@synthesize classNameToIdMap = m_classNameToIdMap;

#pragma mark Object extraction

- (id)objectWithClassName:(NSString *)className id:(NSString *)id
{
    // Get the id map corresponding to the object class name
    NSMutableDictionary *idMap = [self.classNameToIdMap objectForKey:className];
    if (! idMap) {
        return nil;
    }
    
    // Get the object
    return [idMap objectForKey:id];
}

- (NSArray *)objectsWithClassName:(NSString *)className
{
    // Get the id map corresponding to the object class name
    NSMutableDictionary *idMap = [self.classNameToIdMap objectForKey:className];
    if (! idMap) {
        return nil;
    }
    
    // Get the objects
    return [idMap allValues];
}

#pragma mark Object insertion and update

- (void)setObject:(id)object forClassName:(NSString *)className andId:(NSString *)id
{
    // Get the id map corresponding to the object class name
    NSMutableDictionary *idMap = [self.classNameToIdMap objectForKey:className];
    
    // Lazy creation if it does not already exist in cache
    if (! idMap) {
        idMap = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
        [self.classNameToIdMap setObject:idMap forKey:className];
    }
    
    // Add the object
    [idMap setObject:object forKey:id];
}

@end
