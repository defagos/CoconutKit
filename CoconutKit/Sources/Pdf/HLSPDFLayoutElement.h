//
//  HLSPDFLayoutElement.h
//  CoconutKit
//
//  Created by Samuel Défago on 14.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * A protocol to be implemented by layout elements
 */
@protocol HLSPDFLayoutElement <NSObject>

@required

/**
 * Each layout element must implement this method to define how it will be drawn
 */
- (void)draw;

@end
