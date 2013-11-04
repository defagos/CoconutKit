//
//  HLSInMemoryCacheEntry.m
//  CoconutKit
//
//  Created by Samuel Défago on 23.10.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSInMemoryCacheEntry.h"

#import "HLSAssert.h"
#import "HLSLogger.h"

@interface HLSInMemoryCacheEntry ()

@property (nonatomic, weak) NSMutableDictionary *parentItems;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSData *data;

@end

@implementation HLSInMemoryCacheEntry

#pragma mark Object creation and destruction

- (id)initWithParentItems:(NSMutableDictionary *)parentItems
                     name:(NSString *)name
                     data:(NSData *)data
{
    if (self = [super init]) {
        if (! parentItems || ! name || ! data) {
            HLSLoggerError(@"Missing parameter");
            return nil;
        }
        
        self.parentItems = parentItems;
        self.name = name;
        self.data = data;
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

#pragma mark Accessors and mutators

- (NSUInteger)cost
{
    return [self.data length];
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; name: %@; parentItems: %p; cost: %u>",
            [self class],
            self,
            self.name,
            self.parentItems,
            self.cost];
}

@end
