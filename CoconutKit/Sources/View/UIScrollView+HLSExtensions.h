//
//  UIScrollView+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 20.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface UIScrollView (HLSExtensions)

/**
 * Synchronize scrolling of a set of scroll views with the receiver (which becomes the "master scroll view").
 * This makes several kinds of effects possible (most notably parallax scrolling). A scroll view can be a
 * master view at most once.
 * If the bounces parameter is set to YES (and if the master scroll view can itself bounce), synchronized
 * scroll views will go on scrolling when the master view bounces, otherwise they will stop at the
 * scroll boundaries.
 *
 * This method only synchronizes scrolling between scroll views. You still have to align them properly
 * and to set their respective content sizes to get the effect you want
 */
- (void)synchronizeWithScrollViews:(NSArray *)scrollViews bounces:(BOOL)bounces;

/**
 * Remove any previously existing parallax effect added to the receiver
 */
- (void)removeSynchronization;

@end
