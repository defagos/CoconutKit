//
//  HLSExpandingSearchBar.h
//  CoconutKit
//
//  Created by Samuel Défago on 11.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSAnimation.h"

typedef enum {
    HLSExpandingSearchBarAlignmentLeft = 0,
    HLSExpandingSearchBarAlignmentRight,
} HLSExpandingSearchBarAlignment;

@interface HLSExpandingSearchBar : UIView <HLSAnimationDelegate> {
@private
    UISearchBar *m_searchBar;
    UIButton *m_searchButton;
    HLSExpandingSearchBarAlignment m_alignment;
    HLSAnimation *m_animation;
    BOOL m_layoutDone;
}

@property (nonatomic, assign) HLSExpandingSearchBarAlignment alignment;

@end
