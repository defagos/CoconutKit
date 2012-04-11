//
//  Coconut.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 11.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "Coconut.h"

@interface Coconut ()

@property (nonatomic, retain) NSString *name_en;
@property (nonatomic, retain) NSString *name_fr;
@property (nonatomic, retain) NSString *thumbnailImageName;

@end

@implementation Coconut

#pragma mark Class methods

+ (NSArray *)coconutsFromDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *coconuts = [NSMutableArray array];
    for (NSArray *coconutsDicts in [dictionary objectForKey:@"coconuts"]) {
        for (NSDictionary *coconutDict in coconutsDicts) {
            Coconut *coconut = [[[Coconut alloc] init] autorelease];
            coconut.name_en = [coconutDict objectForKey:@"name_en"];
            coconut.name_fr = [coconutDict objectForKey:@"name_fr"];
            [coconuts addObject:coconut];
        }
    }
    return [NSArray arrayWithArray:coconuts];
}

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.name_en = nil;
    self.name_fr = nil;
    self.thumbnailImageName = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize name_en = m_name_en;

@synthesize name_fr = m_name_fr;

@dynamic name;

- (NSString *)name
{
    return [self valueForKey:[@"name_" stringByAppendingString:[NSBundle localization]]];
}

@synthesize thumbnailImageName = m_thumbnailImageName;

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; name: %@; thumbnailImageName: %@>", 
            [self class],
            self,
            self.name,
            self.thumbnailImageName];
}

@end
