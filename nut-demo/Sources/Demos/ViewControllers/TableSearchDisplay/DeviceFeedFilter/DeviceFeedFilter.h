//
//  DeviceFeedFilter.h
//  nut-demo
//
//  Created by Samuel Défago on 2/14/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "DeviceInfo.h"

/**
 * Filter for testing DeviceInfo objects
 */
@interface DeviceFeedFilter : HLSFeedFilter {
@private
    NSString *m_pattern;
    DeviceType m_type;
}

@property (nonatomic, retain) NSString *pattern;
@property (nonatomic, assign) DeviceType type;

@end
