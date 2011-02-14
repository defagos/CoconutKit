//
//  HLSFeedFilter.m
//  nut
//
//  Created by Samuel Défago on 7/18/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSFeedFilter.h"

#import "HLSLogger.h"
#import "HLSRuntimeChecks.h"

@interface HLSFeedFilter ()

// TODO: Probably just a temporary fix: Now a feed filter retains its feed, otherwise problems would occur
//       when deallocating a filter (crashes if the feed has been deallocated before!). This fix works, but
//       it is IMHO ugly to have a filter keep a feed alive
@property (nonatomic, retain) HLSFeed *feed;

@end

@implementation HLSFeedFilter

#pragma mark Object construction and destruction

- (id)initWithFeed:(HLSFeed *)feed
{
    if (self = [super init]) {
        self.feed = feed;
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
    // Get rid of the corresponding cached feed (if any)
    [self.feed discardFilteredFeedForFilter:self];
    
    self.feed = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize feed = m_feed;

#pragma mark Methods to be overridden by subclasses

- (BOOL)matchesEntry:(id)entry
{
    MISSING_METHOD_IMPLEMENTATION();
    return NO;
}

@end
