//
//  HLSKenBurnsSlideshow.h
//  CoconutKit
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

/**
 * A view implementing the Ken Burns effect: A slideshow with random zooming and panning effects, as well as cross dissolve
 * transitions between images.
 *
 * You can instantiate a Ken Burns slide show either using a nib or programmatically. It then suffices to set its
 * images property to the array of images which must be displayed. Other properties provide for further
 * customization.
 *
 * You should not change the frame of a slideshow while it is running. This does not behave properly for the moment.
 *
 * Designated initializer: initWithFrame:
 */
@interface HLSKenBurnsSlideshow : UIView {
@private
    NSArray *m_imageViews;                      // Two image views needed (front / back buffer) to create smooth cross-dissolve transitions
    NSArray *m_imageNamesOrPaths;
    NSMutableArray *m_animations;               // Two animations in parallel (at most)
    BOOL m_running;
    NSInteger m_currentImageIndex;
    NSInteger m_currentImageViewIndex;
    NSTimeInterval m_imageDuration;
    NSTimeInterval m_transitionDuration;
    BOOL m_random;
}

/**
 * An array giving the names (for images inside the main bundle) or the full path of the images to be displayed. Images
 * are displayed in an endless loop, either sequentially or in a random order (see random property). 
 *
 * This property can be changed while the slideshow is running
 */
@property (nonatomic, retain) NSArray *imageNamesOrPaths;

/**
 * How much time an image stays visible. Default is 10 seconds. 
 *
 * This property can be changed while the slideshow is running
 */
@property (nonatomic, assign) NSTimeInterval imageDuration;

/**
 * The duration of the cross dissolve transition between two images. Default is 3 seconds. 
 *
 * This property can be changed while the slideshow is running
 */
@property (nonatomic, assign) NSTimeInterval transitionDuration;

/**
 * If set to YES, images will be played in a random order. If set to NO, they are played sequentially
 * Default is NO
 *
 * This property can be changed while the slideshow is running
 */
@property (nonatomic, assign) BOOL random;

/**
 * Start / stop the slideshow
 */
- (void)play;
- (void)stop;

/**
 * Return YES iff the slideshow is running
 */
- (BOOL)isRunning;

@end
