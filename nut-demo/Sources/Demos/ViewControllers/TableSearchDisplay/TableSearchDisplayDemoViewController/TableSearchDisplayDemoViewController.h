//
//  TableSearchDisplayDemoViewController.h
//  nut-demo
//
//  Created by Samuel Défago on 2/14/11.
//  Copyright 2011 Hortis. All rights reserved.
//

// Forward declarations
@class DeviceFeedFilter;

@interface TableSearchDisplayDemoViewController : HLSTableSearchDisplayViewController {
@private
    HLSFeed *m_deviceFeed;
    DeviceFeedFilter *m_deviceFeedFilter;
}

@end
