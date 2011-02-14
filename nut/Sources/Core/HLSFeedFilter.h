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
 * Abstract class for defining feed filters. To define a filter, simply derive from this class for adding data
 * corresponding to the criteria you want the filter to support, and override matchesEntry.
 *
 * Designated initializer: initWithFeed:
 */
@interface HLSFeedFilter : NSObject {
@private
    HLSFeed *m_feed;                           // Weak pointer to the feed the filter belongs to
}

- (id)initWithFeed:(HLSFeed *)feed;

@property (nonatomic, readonly, retain) HLSFeed *feed;

- (BOOL)matchesEntry:(id)entry;

@end
