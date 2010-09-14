//
//  HLSFeedFilter.h
//  nut
//
//  Created by Samuel Défago on 7/18/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSFeed.h"

// TODO: Implement using NSPredicate. Really flexible.

/**
 * "Pure virtual" methods
 */
@protocol HLSFeedFilterAbstract

@optional
/**
 * Implement this function to implement your own filter logic. The function must return YES if the entry matches the
 * filter criteria, NO otherwise
 */
- (BOOL)matchesEntry:(id)entry;

@end

/**
 * Abstract class for defining feed filters. To define a filter, simply derive from this class for adding data
 * corresponding to the criteria you want the filter to support, and override matchesEntry.
 *
 * Designated initializer: initWithFeed:
 */
@interface HLSFeedFilter : NSObject <HLSFeedFilterAbstract> {
@private
    HLSFeed *m_feed;                           // Weak pointer to the feed the filter belongs to
}

- (id)initWithFeed:(HLSFeed *)feed;

// TODO: Probably just a temporary fix: Now a feed filter retains its feed, otherwise problems would occur
//       when deallocating a filter (crashes if the feed has been deallocated before!). This fix works, but
//       it is IMHO ugly to have a filter keep a feed alive
@property (nonatomic, readonly, retain) HLSFeed *feed;

@end
