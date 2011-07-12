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
    NSString *m_tag;
    NSDictionary *m_userInfo;
}

/**
 * Convenience constructor
 */
+ (HLSStrip *)stripWithBeginPosition:(NSUInteger)beginPosition endPosition:(NSUInteger)endPosition;

/**
 * Create a strip between the specified positions
 */
- (id)initWithBeginPosition:(NSUInteger)beginPosition endPosition:(NSUInteger)endPosition;

/**
 * Position information
 */
@property (nonatomic, readonly, assign) NSUInteger beginPosition;
@property (nonatomic, readonly, assign) NSUInteger endPosition;

/**
 * Testing strips
 */
- (BOOL)isOverlappingWithStrip:(HLSStrip *)strip;
- (BOOL)isContainedInStrip:(HLSStrip *)strip;
- (BOOL)containsPosition:(NSUInteger)position;

/**
 * Use tag and user information to easily convey any information which you might find useful
 */
@property (nonatomic, retain) NSString *tag;
@property (nonatomic, retain) NSDictionary *userInfo;

@end

