//
//  HLSContainerStackView.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/5/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSContainerGroupView.h"

/**
 * Designated initializer: initWithFrame:
 */
@interface HLSContainerStackView : UIView {
@private
    NSMutableArray *m_groupViews;
}

- (NSArray *)contentViews;
- (void)insertContentView:(UIView *)subview atIndex:(NSInteger)index;

- (void)removeContentView:(UIView *)subview;

- (HLSContainerGroupView *)groupViewForContentView:(UIView *)contentView;

@end
