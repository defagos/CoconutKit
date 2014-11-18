//
//  HLSSlideshow.h
//  CoconutKit
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Samuel Défago. All rights reserved.
//

#import "HLSAnimation.h"

/**
 * Slideshow effects. Depending on which effect is applied the images will be scaled to fill or fit the slideshow
 * view frame (preserving their aspect ratio)
 */
typedef NS_ENUM(NSInteger, HLSSlideshowEffect) {
    HLSSlideshowEffectEnumBegin = 0,
    HLSSlideshowEffectNone = HLSSlideshowEffectEnumBegin,                           // No transition between images (aspect fit)
    HLSSlideshowEffectCrossDissolve,                                                // Cross-dissolve transition between images (aspect fit)
    HLSSlideshowEffectKenBurns,                                                     // Ken-Burns effect (random zooming and panning, cross-dissolve, aspect fill)
    HLSSlideshowEffectHorizontalRibbon,                                             // Images slide from left to right (aspect fill)
    HLSSlideshowEffectInverseHorizontalRibbon,                                      // Images slide from right to left (aspect fill)
    HLSSlideshowEffectVerticalRibbon,                                               // Images slide from top to bottom (aspect fill)
    HLSSlideshowEffectInverseVerticalRibbon,                                        // Images slide from bottom to top (aspect fill)
    HLSSlideshowEffectEnumEnd,
    HLSSlideshowEffectEnumSize = HLSSlideshowEffectEnumEnd - HLSSlideshowEffectEnumBegin
};

// Forward declarations
@protocol HLSSlideshowDelegate;

/**
 * A slideshow displaying images using one of several built-in transition effects.
 *
 * You can instantiate a slideshow view either using a nib or programmatically. It then suffices to set its images property 
 * to the array of images which must be displayed. Other properties provide for further customisation, e.g. animation
 * effect or timings.
 *
 * You should not alter the frame of a slideshow while it is running. This is currently not supported.
 */
@interface HLSSlideshow : UIView <HLSAnimationDelegate>

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
 * This property can be changed while the slideshow is running. The images are not changed immediately on screen, 
 * though, one or two additional slideshow animations are required to display the new image set so that the 
 * slideshow does not have to be stopped. If you want the change to happen immediately, stop the slideshow, update its 
 * image set and start it again.
 */
@property (nonatomic, strong) NSArray *imageNamesOrPaths;

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

/**
 * The slideshow delegate
 */
@property (nonatomic, weak) id<HLSSlideshowDelegate> delegate;

/**
 * Slideshow controls
 */
- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;

/**
 * Directly skip to the next or previous image (without animation). If the slideshow displays images randomly,
 * both methods skip to a random image
 */
- (void)skipToNextImage;
- (void)skipToPreviousImage;

/**
 * Directly skip to a specific image (the method does nothing if the image is not loaded into the slideshow)
 */
- (void)skipToImageWithNameOrPath:(NSString *)imageNameOrPath;

/**
 * Return the currently displayed image (when a transition occurs, this method returns the disappearing image
 * until the image has been hidden)
 */
- (NSString *)currentImageNameOrPath;

/**
 * Return YES iff the slideshow is running
 */
@property (nonatomic, readonly, assign, getter=isRunning) BOOL running;

/**
 * Return YES iff the slideshow is paused
 */
@property (nonatomic, readonly, assign, getter=isPaused) BOOL paused;

@end

@protocol HLSSlideshowDelegate <NSObject>

@optional
- (void)slideshow:(HLSSlideshow *)slideshow willShowImageWithNameOrPath:(NSString *)imageNameOrPath;
- (void)slideshow:(HLSSlideshow *)slideshow didShowImageWithNameOrPath:(NSString *)imageNameOrPath;
- (void)slideshow:(HLSSlideshow *)slideshow willHideImageWithNameOrPath:(NSString *)imageNameOrPath;
- (void)slideshow:(HLSSlideshow *)slideshow didHideImageWithNameOrPath:(NSString *)imageNameOrPath;

@end
