//
//  HLSStrip+Friend.h
//  nut
//
//  Created by Samuel Défago on 08.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Interface meant to be used by friend classes of HLSStrip (= classes which must have access to private implementation
 * details)
 */
@interface HLSStrip (Friend)

@property (nonatomic, assign) NSUInteger beginPosition;
@property (nonatomic, assign) NSUInteger endPosition;

@end
