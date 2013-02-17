//
//  UIView+HLSExtensionsTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 23.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "UIView+HLSExtensionsTestCase.h"

@implementation UIView_HLSExtensionsTestCase

#pragma mark Tests

- (void)testTag
{
    UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc] initWithFrame:CGRectZero] autorelease];
    segmentedControl.tag_hls = @"tag";
    GHAssertEqualStrings(segmentedControl.tag_hls, @"tag", nil);
}

- (void)testUserInfo
{
    UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc] initWithFrame:CGRectZero] autorelease];
    segmentedControl.userInfo_hls = [NSDictionary dictionary];
    GHAssertNotNil(segmentedControl.userInfo_hls, nil);
}

@end
