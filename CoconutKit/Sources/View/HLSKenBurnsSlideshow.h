//
//  HLSKenBurnsSlideshow.h
//  CoconutKit
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

extern const NSTimeInterval kKenBurnsSlideshowDefaultDuration;

// Forward declarations
@class HLSAnimation;

@interface HLSKenBurnsSlideshow : UIView {
@private
    UIImageView *m_imageView;
    NSArray *m_images;
    NSArray *m_finalFrames;
    NSArray *m_durations;
    BOOL m_animating;
    NSInteger m_currentImageIndex;
    HLSAnimation *m_animation;
}

- (void)addImage:(UIImage *)image withFinalFrame:(CGRect)finalFrame;
- (void)addImage:(UIImage *)image withFinalFrame:(CGRect)finalFrame duration:(NSTimeInterval)duration;

- (void)startAnimating;
- (void)stopAnimating;

@end
