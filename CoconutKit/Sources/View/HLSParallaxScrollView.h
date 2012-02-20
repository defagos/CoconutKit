//
//  HLSParallaxScrollView.h
//  CoconutKit
//
//  Created by Samuel Défago on 20.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface HLSParallaxScrollView : UIView <UIScrollViewDelegate> {
@private
    UIScrollView *m_contentScrollView;
    NSArray *m_backgroundScrollViews;
    BOOL m_contentViewSet;
}

- (void)setContentView:(UIView *)contentView;
- (void)addBackgroundView:(UIView *)backgroundView;

@end
