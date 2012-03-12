//
//  HLSSlideshow.h
//  CoconutKit
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSAnimation.h"

/**
 * Slideshow effects
 */
typedef enum {
    HLSSlideshowEffectEnumBegin = 0,
    HLSSlideshowEffectNone = HLSSlideshowEffectEnumBegin,                           // No transition between images
    HLSSlideshowEffectCrossDissolve,                                                // Cross-dissolve transition between images
    HLSSlideshowEffectKenBurns,                                                     // Ken-Burns effect (random zooming and panning, cross-dissolve)
    HLSSlideshowEffectHorizontalRibbon,                                             // Images slide from left to right
    HLSSlideshowEffectInverseHorizontalRibbon,                                      // Images slide from right to left
    HLSSlideshowEffectVerticalRibbon,                                               // Images slide from top to bottom
    HLSSlideshowEffectInverseVerticalRibbon,                                        // Images slide from bottom to top
    HLSSlideshowEffectEnumEnd,
    HLSSlideshowEffectEnumSize = HLSSlideshowEffectEnumEnd - HLSSlideshowEffectEnumBegin
} HLSSlideshowEffect;

// Forward declarations
@protocol HLSSlideshowDelegate;

/**
 * A slideshow displaying images using one of several built-in transition effects.
 *
 * You can instantiate a slideshow view either using a nib or programmatically. It then suffices to set its images property 
 * to the array of images which must be displayed. Other properties provide for further customization, e.g. animation
 * effect or timings.
 *
 * You should not alter the frame of a slideshow while it is running. This is currently not supported.
 *
 * Designated initializer: initWithFrame:
 */
@interface HLSSlideshow : UIView <HLSAnimationDelegate> {
@private
    HLSSlideshowEffect m_effect;
    NSArray *m_imageViews;                      // Two image views needed (front / back buffer) to create smooth cross-dissolve transitions
    NSArray *m_imageNamesOrPaths;
    NSInteger m_currentImageIndex;
    NSInteger m_nextImageIndex;
    NSInteger m_currentImageViewIndex;
    HLSAnimation *m_animation;
    NSTimeInterval m_imageDuration;
    NSTimeInterval m_transitionDuration;
    BOOL m_random;
    id<HLSSlideshowDelegate> m_delegate;
}

/**
 * The transition effect to be applied
 *
 * This property cannot be changed while the slideshow is running
 */
@property (nonatomic, assign) HLSSlideshowEffect effect;

/**
 * An array giving the names (for images inside the main bundle) or the full path of the images to be displayed. Images
 * are displayed in an endless loop, either sequentially or in a random order (see random property). 
 *
 * This property can be changed while the slideshow is running
 */
@property (nonatomic, retain) NSArray *imageNamesOrPaths;

/**
 * How much time an image stays visible alone. Default is 4 seconds. Must be > 0
 *
 * This property can be changed while the slideshow is running
 */
@property (nonatomic, assign) NSTimeInterval imageDuration;

/**
 * The duration of the transition between two images (this setting is ignored by slideshows which do not involve a 
 * transition between images). Default is 3 seconds. Must be >= 0
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

@property (nonatomic, assign) id<HLSSlideshowDelegate> delegate;

/**
 * Start / stop the slideshow
 */
- (void)play;
- (void)stop;

/**
 * Interrupts the current transition and moves to the next or previous image directly (without animation)
 */
- (void)skipToNextImage;
- (void)skipToPreviousImage;

/**
 * Return YES iff the slideshow is running
 */
- (BOOL)isRunning;

@end

@protocol HLSSlideshowDelegate <NSObject>

@optional
- (void)slideshow:(HLSSlideshow *)slideshow willShowImageAtIndex:(NSUInteger)index;
- (void)slideshow:(HLSSlideshow *)slideshow didShowImageAtIndex:(NSUInteger)index;
- (void)slideshow:(HLSSlideshow *)slideshow willHideImageAtIndex:(NSUInteger)index;
- (void)slideshow:(HLSSlideshow *)slideshow didHideImageAtIndex:(NSUInteger)index;

@end
