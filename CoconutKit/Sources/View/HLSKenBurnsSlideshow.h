//
//  HLSKenBurnsSlideshow.h
//  CoconutKit
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

@interface HLSKenBurnsSlideshow : UIView {
@private
    NSArray *m_imageViews;                      // Two image views needed (front / back buffer) to create smooth cross-dissolve transitions
    NSArray *m_images;
    NSMutableArray *m_animations;               // Two animations in parallel (at most)
    BOOL m_animating;
    NSInteger m_currentImageIndex;
}

@property (nonatomic, retain) NSArray *images;

- (void)play;
- (void)stop;

@end
