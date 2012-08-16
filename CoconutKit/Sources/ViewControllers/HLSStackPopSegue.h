//
//  HLSStackPopSegue.h
//  CoconutKit
//
//  Created by Samuel Défago on 27.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * Segue class for popping view controllers out of an HLSStackController when using storyboards. The source 
 * view controller can implement the -prepareForSegue:sender: method to further customize transition
 * properties
 *
 * The destination view controller is not used. Simply bind the segue from the view controller to
 * pop to another one (connecting it to the view controller below in the stack is a good idea 
 * since it makes sense graphically, but this is not needed; you can e.g. bind the segue from the 
 * view controller to itself if you want)
 */
@interface HLSStackPopSegue : UIStoryboardSegue {
@private
    BOOL m_animated;
}

/**
 * Animated transition
 * Default is YES
 */
@property (nonatomic, assign) BOOL animated;

@end
