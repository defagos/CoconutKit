//
//  HLSStrip.h
//  nut
//
//  Created by Samuel Défago on 24.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Lightweight object representing a strip in the container view
 *
 * Designated intializer: initWithBeginPosition:endPosition:
 */
@interface HLSStrip : NSObject {
@private
    NSUInteger m_beginPosition;
    NSUInteger m_endPosition;
}

+ (HLSStrip *)stripWithBeginPosition:(NSUInteger)beginPosition endPosition:(NSUInteger)endPosition;

- (id)initWithBeginPosition:(NSUInteger)beginPosition endPosition:(NSUInteger)endPosition;

@property (nonatomic, readonly, assign) NSUInteger beginPosition;
@property (nonatomic, readonly, assign) NSUInteger endPosition;

- (BOOL)isOverlappingWithStrip:(HLSStrip *)strip;
- (BOOL)isContainedInStrip:(HLSStrip *)strip;

- (BOOL)containsPosition:(NSUInteger)position;

@end

