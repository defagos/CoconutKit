//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSManagedObject+HLSExtensions.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import "HLSManagedObjectCopying.h"
#import "HLSModelManager.h"
#import "NSObject+HLSExtensions.h"

@implementation NSManagedObject (HLSExtensions)

#pragma mark Class methods

+ (instancetype)insertIntoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSParameterAssert(managedObjectContext);
    
    return [NSEntityDescription insertNewObjectForEntityForName:[self className]
                                         inManagedObjectContext:managedObjectContext];
}

+ (instancetype)insert
{
    return [self insertIntoManagedObjectContext:[HLSModelManager currentModelContext]];
}

+ (NSArray *)filteredObjectsUsingPredicate:(NSPredicate *)predicate
                    sortedUsingDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors
                    inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSParameterAssert(managedObjectContext);
    HLSAssertObjectsInEnumerationAreKindOfClass(sortDescriptors, NSSortDescriptor);
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[self className]
                                                         inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entityDescription;
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
                    sortedUsingDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors
{
    return [self filteredObjectsUsingPredicate:predicate
                        sortedUsingDescriptors:sortDescriptors 
                        inManagedObjectContext:[HLSModelManager currentModelContext]];
}

+ (NSArray *)filteredObjectsUsingPredicate:(NSPredicate *)predicate
                     sortedUsingDescriptor:(NSSortDescriptor *)sortDescriptor
                    inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSArray<NSSortDescriptor *> *sortDescriptors = sortDescriptor ? @[sortDescriptor] : nil;
    return [self filteredObjectsUsingPredicate:predicate
                        sortedUsingDescriptors:sortDescriptors 
                        inManagedObjectContext:managedObjectContext];
}

+ (NSArray *)filteredObjectsUsingPredicate:(NSPredicate *)predicate
                     sortedUsingDescriptor:(NSSortDescriptor *)sortDescriptor
{
    NSArray<NSSortDescriptor *> *sortDescriptors = sortDescriptor ? @[sortDescriptor] : nil;
    return [self filteredObjectsUsingPredicate:predicate
                        sortedUsingDescriptors:sortDescriptors];
}

+ (NSArray *)allObjectsSortedUsingDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors
                       inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [self filteredObjectsUsingPredicate:nil 
                        sortedUsingDescriptors:sortDescriptors 
                        inManagedObjectContext:managedObjectContext];
}

+ (NSArray *)allObjectsSortedUsingDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors
{
    return [self allObjectsSortedUsingDescriptors:sortDescriptors inManagedObjectContext:[HLSModelManager currentModelContext]];
}

+ (NSArray *)allObjectsSortedUsingDescriptor:(NSSortDescriptor *)sortDescriptor
                      inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSArray<NSSortDescriptor *> *sortDescriptors = sortDescriptor ? @[sortDescriptor] : nil;
    return [self allObjectsSortedUsingDescriptors:sortDescriptors
                           inManagedObjectContext:managedObjectContext];
}

+ (NSArray *)allObjectsSortedUsingDescriptor:(NSSortDescriptor *)sortDescriptor
{
    NSArray<NSSortDescriptor *> *sortDescriptors = sortDescriptor ? @[sortDescriptor] : nil;
    return [self allObjectsSortedUsingDescriptors:sortDescriptors];
}

+ (NSArray *)allObjectsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [self allObjectsSortedUsingDescriptors:nil 
                           inManagedObjectContext:managedObjectContext];
}

+ (NSArray *)allObjects
{
    return [self allObjectsInManagedObjectContext:[HLSModelManager currentModelContext]];
}

+ (void)deleteAllObjectsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSArray *allObjects = [self allObjects];
    for (NSManagedObject *managedObject in allObjects) {
        [managedObjectContext deleteObject:managedObject];
    }
}

+ (void)deleteAllObjects
{
    [self deleteAllObjectsInManagedObjectContext:[HLSModelManager currentModelContext]];
}

#pragma mark Creating a copy

- (NSManagedObject *)duplicate
{
    if (! [self conformsToProtocol:@protocol(HLSManagedObjectCopying)]) {
        return nil;
    }
    
    // Create the deep copy
    NSManagedObject *objectCopy = [NSEntityDescription insertNewObjectForEntityForName:self.entity.name
                                                                inManagedObjectContext:self.managedObjectContext];
        
    // Get keys to exclude (if any)
    NSSet *keysToExclude = nil;
    NSManagedObject<HLSManagedObjectCopying> *managedObjectCopyable = (NSManagedObject<HLSManagedObjectCopying> *)self;
    if ([managedObjectCopyable respondsToSelector:@selector(keysToExclude)]) {
        keysToExclude = managedObjectCopyable.keysToExclude;
    }
    
    // Copy attributes (shallow copy for all: Those are of "primitive" immutable types anyway)
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:self.entity.name
                                                         inManagedObjectContext:self.managedObjectContext];
    NSDictionary<NSString *, NSAttributeDescription *> *attributes = entityDescription.attributesByName;
    for (NSString *attributeName in attributes.allKeys) {
        if ([keysToExclude containsObject:attributeName]) {
            continue;
        }
        [objectCopy setValue:[self valueForKey:attributeName] forKey:attributeName];
    }
    
    // Copy relationships
    NSDictionary<NSString *, NSRelationshipDescription *> *relationships = entityDescription.relationshipsByName;
    for (NSString *relationshipName in relationships.allKeys) {
        if ([keysToExclude containsObject:relationshipName]) {
            continue;
        }
        
        // Deep copy owned objects implementing the NSManagedObjectCopying protocol
        NSRelationshipDescription *relationshipDescription = relationships[relationshipName];
        if (relationshipDescription.deleteRule == NSCascadeDeleteRule) {
            // To-many relationship
            if (relationshipDescription.toMany) {
                // The set of owned objects might be altered when we duplicate them below. To avoid iterating
                // over mutating sets, we copy it first
                NSSet *ownedObjects = [[managedObjectCopyable valueForKey:relationshipName] copy];
                NSMutableSet *ownedObjectCopies = [NSMutableSet set];
                for (NSManagedObject *ownedObject in ownedObjects) {
                    NSManagedObject *ownedObjectCopy = [ownedObject duplicate];
                    if (ownedObjectCopy) {
                        [ownedObjectCopies addObject:ownedObjectCopy];
                    }
                    else {
                        [ownedObjectCopies addObject:ownedObject];
                    }   
                }
                [objectCopy setValue:[ownedObjectCopies copy] forKey:relationshipName];
            }
            // To-one relationship
            else {
                NSManagedObject *ownedObject = [managedObjectCopyable valueForKey:relationshipName];
                NSManagedObject *ownedObjectCopy = [ownedObject duplicate];
                if (ownedObjectCopy) {
                    [objectCopy setValue:ownedObjectCopy forKey:relationshipName];
                }
                else {
                    [objectCopy setValue:ownedObject forKey:relationshipName];
                }
            }
        }
        // Shallow copy in all other cases
        else {
            [objectCopy setValue:[managedObjectCopyable valueForKey:relationshipName] forKey:relationshipName];
        }
    }
    
    return objectCopy;
}

@end
