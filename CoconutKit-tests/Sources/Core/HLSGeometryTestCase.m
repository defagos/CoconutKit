//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSGeometryTestCase.h"

@implementation HLSGeometryTestCase

#pragma mark Helpers

- (void)assertRect:(CGRect)rect1 isEqualToRect:(CGRect)rect2
{
    XCTAssertTrue(CGRectEqualToRect(rect1, rect2));
}

- (void)assertSize:(CGSize)size1 isEqualToSize:(CGSize)size2
{
    XCTAssertTrue(CGSizeEqualToSize(size1, size2));
}

#pragma mark Tests

- (void)testRectForSizeContainedInRect
{
    CGSize size = CGSizeMake(100.f, 20.f);
    CGRect targetRect = CGRectMake(0.f, 0.f, 50.f, 100.f);
    
    CGRect scaleToFillRect = HLSRectForSizeContainedInRect(size, targetRect, HLSContentModeScaleToFill);
    [self assertRect:scaleToFillRect isEqualToRect:CGRectMake(0.f, 0.f, 50.f, 100.f)];
    
    CGRect scaleAspectFitRect = HLSRectForSizeContainedInRect(size, targetRect, HLSContentModeScaleAspectFit);
    [self assertRect:scaleAspectFitRect isEqualToRect:CGRectMake(0.f, 45.f, 50.f, 10.f)];
    
    CGRect scaleAspectFillRect = HLSRectForSizeContainedInRect(size, targetRect, HLSContentModeScaleAspectFill);
    [self assertRect:scaleAspectFillRect isEqualToRect:CGRectMake(-225.f, 0.f, 500.f, 100.f)];
    
    CGRect centerRect = HLSRectForSizeContainedInRect(size, targetRect, HLSContentModeCenter);
    [self assertRect:centerRect isEqualToRect:CGRectMake(-25.f, 40.f, 100.f, 20.f)];

    CGRect topRect = HLSRectForSizeContainedInRect(size, targetRect, HLSContentModeTop);
    [self assertRect:topRect isEqualToRect:CGRectMake(-25.f, 0.f, 100.f, 20.f)];

    CGRect bottomRect = HLSRectForSizeContainedInRect(size, targetRect, HLSContentModeBottom);
    [self assertRect:bottomRect isEqualToRect:CGRectMake(-25.f, 80.f, 100.f, 20.f)];

    CGRect leftRect = HLSRectForSizeContainedInRect(size, targetRect, HLSContentModeLeft);
    [self assertRect:leftRect isEqualToRect:CGRectMake(0.f, 40.f, 100.f, 20.f)];

    CGRect rightRect = HLSRectForSizeContainedInRect(size, targetRect, HLSContentModeRight);
    [self assertRect:rightRect isEqualToRect:CGRectMake(-50.f, 40.f, 100.f, 20.f)];
    
    CGRect topLeftRect = HLSRectForSizeContainedInRect(size, targetRect, HLSContentModeTopLeft);
    [self assertRect:topLeftRect isEqualToRect:CGRectMake(0.f, 0.f, 100.f, 20.f)];

    CGRect topRightRect = HLSRectForSizeContainedInRect(size, targetRect, HLSContentModeTopRight);
    [self assertRect:topRightRect isEqualToRect:CGRectMake(-50.f, 0.f, 100.f, 20.f)];

    CGRect bottomLeftRect = HLSRectForSizeContainedInRect(size, targetRect, HLSContentModeBottomLeft);
    [self assertRect:bottomLeftRect isEqualToRect:CGRectMake(0.f, 80.f, 100.f, 20.f)];

    CGRect bottomRightRect = HLSRectForSizeContainedInRect(size, targetRect, HLSContentModeBottomRight);
    [self assertRect:bottomRightRect isEqualToRect:CGRectMake(-50.f, 80.f, 100.f, 20.f)];
}

- (void)testSizeForAspectFittingInSize
{
    CGSize size = CGSizeMake(100.f, 20.f);
    CGSize targetSize = CGSizeMake(50.f, 100.f);
    
    CGSize aspectFitSize = HLSSizeForAspectFittingInSize(size, targetSize);
    [self assertSize:aspectFitSize isEqualToSize:CGSizeMake(50.f, 10.f)];
}

- (void)testSizeForAspectFillingInSize
{
    CGSize size = CGSizeMake(100.f, 20.f);
    CGSize targetSize = CGSizeMake(50.f, 100.f);
    
    CGSize aspectFillSize = HLSSizeForAspectFillingInSize(size, targetSize);
    [self assertSize:aspectFillSize isEqualToSize:CGSizeMake(500.f, 100.f)];
}

@end
