//
//  DeviceFeedFilter.m
//  nut-demo
//
//  Created by Samuel Défago on 2/14/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "DeviceFeedFilter.h"

@implementation DeviceFeedFilter

#pragma mark Object creation and destruction

- (id)initWithFeed:(HLSFeed *)feed
{
    if (self = [super initWithFeed:feed]) {
        self.type = DeviceTypeAll;
    }
    return self;
}

- (void)dealloc
{
    self.pattern = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize pattern = m_pattern;

@synthesize type = m_type;

#pragma mark Testing objects

- (BOOL)matchesEntry:(id)entry
{
    DeviceInfo *deviceInfo = entry;
    
    // Try to locate the pattern in the name (if any)
    if ([self.pattern length] != 0) {
        NSRange prefixRange = [deviceInfo.name rangeOfString:self.pattern
                                                     options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch];
        if (prefixRange.length == 0) {
            return NO;
        }        
    }
    
    // Check against device type (if any)
    if (self.type != DeviceTypeAll && deviceInfo.type != self.type) {
        return NO;
    }
    
    return YES;
}

@end
