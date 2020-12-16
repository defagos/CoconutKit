//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSInMemoryCacheEntry.h"

@interface HLSInMemoryCacheEntry ()

@property (nonatomic) NSMutableDictionary<NSString *, id> *parentItems;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSData *data;

@end

@implementation HLSInMemoryCacheEntry

#pragma mark Object creation and destruction

- (instancetype)initWithParentItems:(NSMutableDictionary<NSString *, id> *)parentItems
                               name:(NSString *)name
                               data:(NSData *)data
{
    NSParameterAssert(parentItems);
    NSParameterAssert(name);
    NSParameterAssert(data);
    
    if (self = [super init]) {
        self.parentItems = parentItems;
        self.name = name;
        self.data = data;
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (instancetype)init
{
    return nil;
}

#pragma clang diagnostic pop

#pragma mark Accessors and mutators

- (NSUInteger)cost
{
    return self.data.length;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; name: %@; parentItems: %p; cost: %lu>",
            [self class],
            self,
            self.name,
            self.parentItems,
            (unsigned long)self.cost];
}

@end
