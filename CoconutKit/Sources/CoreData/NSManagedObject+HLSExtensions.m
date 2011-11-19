//
//  NSManagedObject+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 21.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "NSManagedObject+HLSExtensions.h"

#import "HLSCategoryLinker.h"
#import "HLSLogger.h"
#import "HLSModelManager.h"
#import "NSObject+HLSExtensions.h"

HLSLinkCategory(NSManagedObject_HLSExtensions)

@implementation NSManagedObject (HLSExtensions)

#pragma mark Query helpers

+ (id)insertIntoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self className] inManagedObjectContext:managedObjectContext];
}

+ (id)insert
{
    return [self insertIntoManagedObjectContext:[HLSModelManager defaultModelContext]];
}

+ (NSArray *)filteredObjectsUsingPredicate:(NSPredicate *)predicate
                    sortedUsingDescriptors:(NSArray *)sortDescriptors
                    inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[self className]
                                                         inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [fetchRequest setEntity:entityDescription];
    fetchRequest.sortDescriptors = sortDescriptors;
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    NSArray *objects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        HLSLoggerError(@"Could not retrieve objects; reason: %@", error);
        return nil;
    }
    
    return objects;
}

+ (NSArray *)filteredObjectsUsingPredicate:(NSPredicate *)predicate
                    sortedUsingDescriptors:(NSArray *)sortDescriptors
{
    return [self filteredObjectsUsingPredicate:predicate
                        sortedUsingDescriptors:sortDescriptors 
                        inManagedObjectContext:[HLSModelManager defaultModelContext]];
}

+ (NSArray *)allObjectsSortedUsingDescriptors:(NSArray *)sortDescriptors
                       inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [self filteredObjectsUsingPredicate:nil 
                        sortedUsingDescriptors:sortDescriptors 
                        inManagedObjectContext:managedObjectContext];
}

+ (NSArray *)allObjectsSortedUsingDescriptors:(NSArray *)sortDescriptors
{
    return [self allObjectsSortedUsingDescriptors:sortDescriptors inManagedObjectContext:[HLSModelManager defaultModelContext]];
}

+ (NSArray *)allObjectsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [self allObjectsSortedUsingDescriptors:nil 
                           inManagedObjectContext:managedObjectContext];
}

+ (NSArray *)allObjects
{
    return [self allObjectsInManagedObjectContext:[HLSModelManager defaultModelContext]];
}

@end
