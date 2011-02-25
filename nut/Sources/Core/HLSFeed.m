//
//  HLSFeed.m
//  nut
//
//  Created by Samuel Défago on 7/17/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSFeed.h"

#import "HLSFeedFilter.h"
#import "HLSRuntimeChecks.h"

#pragma mark -
#pragma mark FilteredFeed class interface

/**
 * Class representing a filtered view of the raw feed
 *
 * Designated initializer: initWithFilter:
 */
@interface FilteredFeed : NSObject {
@private
    HLSFeedFilter *m_filter;                   // Weak pointer to the filter (its lifetime is bigger than the corresponding filtered feed, this is therefore safe)
    NSArray *m_entries;                     // All raw feed entries which match the filter criteria
}

- (id)initWithFilter:(HLSFeedFilter *)filter;

@property (nonatomic, assign) HLSFeedFilter *filter;

@property (nonatomic, retain) NSArray *entries;

/**
 * Updates the filtered feed by applying the filter to the raw feed again
 */
- (void)update;

@end

#pragma mark -
#pragma mark HLSFeed class interface extension

@interface HLSFeed ()

/**
 * Return an array corresponding to all entries matching a filter
 */
- (NSArray *)entriesExtractedWithFilter:(HLSFeedFilter *)filter;

/**
 * Return the filtered feed obtained by applying a filter to the raw feed, creating it if it does not already
 * exist
 */
- (FilteredFeed *)filteredFeedUsingFilter:(HLSFeedFilter *)filter;

/**
 * Build a unique string identifier from a filter
 */
- (NSString *)stringIdentifierFromFilter:(HLSFeedFilter *)filter;

/**
 * Synchronize the filtered feeds with the raw feed. Must be called when the raw feed is updated
 */
- (void)updateFilteredFeeds;

@property (nonatomic, retain) NSMutableDictionary *filteredFeeds;

@end

#pragma mark -
#pragma mark FilteredFeed class implementation

@implementation FilteredFeed

- (id)initWithFilter:(HLSFeedFilter *)filter
{
    if ((self = [super init])) {
        self.filter = filter;
        [self update];
    }
    return self;
}

- (id)init
{
    FORBIDDEN_INHERITED_METHOD();
    return nil;
}

- (void)dealloc
{
    self.filter = nil;
    self.entries = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize filter = m_filter;

@synthesize entries = m_entries;

- (void)update
{
    self.entries = [self.filter.feed entriesExtractedWithFilter:self.filter];
}

@end

#pragma mark -
#pragma mark HLSFeed class implementation

@implementation HLSFeed

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.filteredFeeds = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    self.entries = nil;
    self.filteredFeeds = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize entries = m_entries;

- (void)setEntries:(NSArray *)entries
{
    // Check for self-assignment
    if (m_entries == entries) {
        return;
    }
    
    // Update the value
    [m_entries release];
    m_entries = [entries retain];
    
    // Keep all filtered views in sync
    [self updateFilteredFeeds];
}

@synthesize filteredFeeds = m_filteredFeeds;

#pragma mark Raw feed access functions

- (NSUInteger)count
{
    return [self countMatchingFilter:nil];
}

- (id)entryAtIndex:(NSUInteger)index
{
    return [self entryAtIndex:index matchingFilter:nil];
}

#pragma mark Functions for accessing filtered feeds

- (NSArray *)entriesMatchingFilter:(HLSFeedFilter *)filter
{
    // If no filter is applied
    if (! filter) {
        return self.entries;
    }
    // A filter is applied
    else {
        // Retrieve the corresponding feed (creating one lazily if none is available)
        FilteredFeed *filteredFeed = [self filteredFeedUsingFilter:filter];
        return filteredFeed.entries;
    }
}

- (NSUInteger)countMatchingFilter:(HLSFeedFilter *)filter
{
    // If no filter is applied
    if (! filter) {
        return [self.entries count];
    }
    // A filter is applied
    else {
        // Retrieve the corresponding feed (creating one lazily if none is available)
        FilteredFeed *filteredFeed = [self filteredFeedUsingFilter:filter];
        return [filteredFeed.entries count];
    }
}

- (id)entryAtIndex:(NSUInteger)index matchingFilter:(HLSFeedFilter *)filter
{
    // If no filter is applied
    if (! filter) {
        return [self.entries objectAtIndex:index];
    }
    // A filter is applied
    else {
        // Retrieve the corresponding feed (creating one lazily if none is available)
        FilteredFeed *filteredFeed = [self filteredFeedUsingFilter:filter];
        return [filteredFeed.entries objectAtIndex:index];
    }
}

#pragma mark Filtering results

- (NSArray *)entriesExtractedWithFilter:(HLSFeedFilter *)filter
{
    NSMutableArray *entries = [NSMutableArray array];
    for (id entry in self.entries) {
        // Check the entry against the filter criteria
        if (! [filter matchesEntry:entry]) {
            continue;
        }
        
        // Criteria match; add the entry to the filtered feed
        [entries addObject:entry];
    }
    return [NSArray arrayWithArray:entries];
}

#pragma mark Filtered feed management

- (FilteredFeed *)filteredFeedUsingFilter:(HLSFeedFilter *)filter
{    
    // Try to retrieve the feed corresponding to the filter
    NSString *key = [self stringIdentifierFromFilter:filter];
    FilteredFeed *filteredFeed = [self.filteredFeeds objectForKey:key];
    
    // If it does not exist, create it
    if (! filteredFeed) {
        filteredFeed = [[[FilteredFeed alloc] initWithFilter:filter] autorelease];
        [self.filteredFeeds setObject:filteredFeed forKey:key];
    }
    return filteredFeed;
}

- (void)discardFilteredFeedForFilter:(HLSFeedFilter *)filter
{
    NSString *key = [self stringIdentifierFromFilter:filter];
    [self.filteredFeeds removeObjectForKey:key];
}

- (NSString *)stringIdentifierFromFilter:(HLSFeedFilter *)filter
{
    // We simply use the object address (converted as string) as identifier. This is guaranteed to be unique
    return [NSString stringWithFormat:@"%p", filter];
}

- (void)updateFilteredFeeds
{
    for (FilteredFeed *filteredFeed in [self.filteredFeeds allValues]) {
        [filteredFeed update];
    }
}

@end
