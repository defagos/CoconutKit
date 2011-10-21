//
//  NSManagedObject+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 21.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

@interface NSManagedObject (HLSExtensions)

+ (id)insertIntoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (id)insert;

+ (NSArray *)filteredObjectsUsingPredicate:(NSPredicate *)predicate
                    sortedUsingDescriptors:(NSArray *)sortDescriptors
                    inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)filteredObjectsUsingPredicate:(NSPredicate *)predicate
                    sortedUsingDescriptors:(NSArray *)sortDescriptors;

+ (NSArray *)allObjectsSortedUsingDescriptors:(NSArray *)sortDescriptors
                       inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)allObjectsSortedUsingDescriptors:(NSArray *)sortDescriptors;

+ (NSArray *)allObjectsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)allObjects;

@end
