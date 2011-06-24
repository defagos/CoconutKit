//
//  HLSStrip.h
//  nut
//
//  Created by Samuel Défago on 24.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Lightweight object representing a strip in the container view
 *
 * Designated intializer: init
 */
@interface HLSStrip : NSObject {
@private
    NSUInteger m_beginPosition;
    NSUInteger m_endPosition;
}

+ (HLSStrip *)stripWithBeginPosition:(NSUInteger)beginPosition endPosition:(NSUInteger)endPosition;
+ (HLSStrip *)strip;

@property (nonatomic, assign) NSUInteger beginPosition;
@property (nonatomic, assign) NSUInteger endPosition;

- (BOOL)isOverlappingWithStrip:(HLSStrip *)strip;
- (BOOL)isContainedInStrip:(HLSStrip *)strip;

- (BOOL)containsPosition:(NSUInteger)position;

@end

