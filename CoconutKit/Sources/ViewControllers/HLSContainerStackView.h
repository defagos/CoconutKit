//
//  HLSContainerStackView.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/5/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSContainerGroupView.h"

/**
 * TODO: Document: Use the standard view hierarchy management methods
 *
 * Designated initializer: initWithFrame:
 */
@interface HLSContainerStackView : UIView {
@private
    NSMutableArray *m_groupViews;
}

- (HLSContainerGroupView *)groupViewForSubview:(UIView *)subview;

- (void)removeSubview:(UIView *)subview;

@end
