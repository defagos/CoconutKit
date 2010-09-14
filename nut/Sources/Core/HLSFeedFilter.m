//
//  HLSFeedFilter.m
//  nut
//
//  Created by Samuel Défago on 7/18/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSFeedFilter.h"

#import "HLSLogger.h"

@interface HLSFeedFilter ()

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

- (void)dealloc
{
    // Get rid of the corresponding cached feed (if any)
    [self.feed discardFilteredFeedForFilter:self];
    
    self.feed = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize feed = m_feed;

@end
