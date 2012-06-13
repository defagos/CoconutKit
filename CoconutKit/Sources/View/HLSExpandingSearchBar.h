//
//  HLSExpandingSearchBar.h
//  CoconutKit
//
//  Created by Samuel Défago on 11.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSAnimation.h"

// Search button alignment
typedef enum {
    HLSExpandingSearchBarAlignmentLeft = 0,
    HLSExpandingSearchBarAlignmentRight,
} HLSExpandingSearchBarAlignment;

// Forward declarations
@protocol HLSExpandingSearchBarDelegate;

@interface HLSExpandingSearchBar : UIView <HLSAnimationDelegate, UISearchBarDelegate> {
@private
    UISearchBar *m_searchBar;
    UIButton *m_searchButton;
    HLSExpandingSearchBarAlignment m_alignment;
    id<HLSExpandingSearchBarDelegate> m_delegate;
    HLSAnimation *m_animation;
    BOOL m_layoutDone;
    BOOL m_expanded;
}

@property (nonatomic, assign) HLSExpandingSearchBarAlignment alignment;

@property (nonatomic, assign) id<HLSExpandingSearchBarDelegate> delegate;

- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated;

// TODO: Expose some (most!) UISearchBar methods

@end

@protocol HLSExpandingSearchBarDelegate <NSObject>

// Called when the search bar expands or collapses
- (BOOL)expandingSearchBarDidExpand:(HLSExpandingSearchBar *)searchBar animated:(BOOL)animated;
- (BOOL)expandingSearchBarDidCollapse:(HLSExpandingSearchBar *)searchBar animated:(BOOL)animated;

// Refer to the documentation of the same methods declared by UISearchBarDelegate
- (BOOL)expandingSearchBarShouldBeginEditing:(HLSExpandingSearchBar *)searchBar;
- (void)expandingSearchBarTextDidBeginEditing:(HLSExpandingSearchBar *)searchBar;
- (BOOL)expandingSearchBarShouldEndEditing:(HLSExpandingSearchBar *)searchBar;
- (void)expandingSearchBarTextDidEndEditing:(HLSExpandingSearchBar *)searchBar;
- (void)expandingSearchBar:(HLSExpandingSearchBar *)searchBar textDidChange:(NSString *)searchText;
- (BOOL)expandingSearchBar:(HLSExpandingSearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

- (void)expandingSearchBarSearchButtonClicked:(HLSExpandingSearchBar *)searchBar;
- (void)expandingSearchBarBookmarkButtonClicked:(HLSExpandingSearchBar *)searchBar;
- (void)expandingSearchBarCancelButtonClicked:(HLSExpandingSearchBar *) searchBar;
- (void)expandingSearchBarResultsListButtonClicked:(HLSExpandingSearchBar *)searchBar;

- (void)expandingSearchBar:(HLSExpandingSearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope;

@end
