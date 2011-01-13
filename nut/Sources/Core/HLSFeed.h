//
//  HLSFeed.h
//  nut
//
//  Created by Samuel Défago on 7/17/10.
//  Copyright 2010 Hortis. All rights reserved.
//

// Forward declarations
@class HLSFeedFilter;

/**
 * Class for working with data feeds more easily. Data feeds are simply ordered collections of objects, 
 * usually retrieved from a data source (e.g. a web service, a database, etc.), and to which filters can be
 * applied to obtain subcollections matching some sets of criteria. This class is therefore especially useful
 * when dealing with table view and search display controllers.
 
 * A filtered feed is in fact just a mask on top of the raw feed. Filtered views therefore do not duplicate 
 * feed entries, and preserve their original ordering. This not only saves memory resources, but also guarantees
 * that the unfiltered entries and filtered entries are the same. If feed entries are updated asynchronously (e.g. 
 * thumbnail downloading), then the update will be available whether you are currently dealing with the raw feed 
 * or a filtered subset.
 *
 * Once you have defined a filter and used it by accessing the filtered feed once, the resulting filtered feed
 * is cached within the HLSFeed object. The object remains alive until the filter object itself is deallocated. It
 * is therefore important to manage filter object allocations properly, otherwise you could end up keeping
 * unused results in cache.
 *
 * The filtered views of the raw feed are guaranteed to be kept in sync with the raw feed. For performance reasons,
 * the raw feed can only be updated in a single batch (we cannot afford updating all filtered views whenever
 * an entry is added or removed).
 *
 * Designated initializer: init
 */
@interface HLSFeed : NSObject {
@private
    NSArray *m_entries;                                 // Raw feed entries
    NSMutableDictionary *m_filteredFeeds;               // Maps HLSFeedFilter objects to the corresponding FilteredFeed objects
}

/**
 * Access to the raw feed
 */
- (NSUInteger)count;
- (id)entryAtIndex:(NSUInteger)index;

/**
 * Access to filtered views of the raw feed. Results are cached as long as the filter object is kept alive.
 */
- (NSArray *)entriesMatchingFilter:(HLSFeedFilter *)filter;
- (NSUInteger)countMatchingFilter:(HLSFeedFilter *)filter;
- (id)entryAtIndex:(NSUInteger)index matchingFilter:(HLSFeedFilter *)filter;

/**
 * Release the filtered feed corresponding to a filter; call this function if you want to release a filtered feed without
 * waiting the filter itself to be destroyed. In general you should not need to call this function since you can rely on 
 * the fact that deallocation of a HLSFeedFilter object automatically releases the associated filtered feed in cache
 */
- (void)discardFilteredFeedForFilter:(HLSFeedFilter *)filter;

/**
 * Changes the feed contents in a single batch. Filtered feeds are synchronized to reflect the new data
 */
@property (nonatomic, retain) NSArray *entries;

@end
