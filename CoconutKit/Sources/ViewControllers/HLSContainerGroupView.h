//
//  HLSContainerGroupView.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/5/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * Designated initializer: initWithFrame:view:
 */
@interface HLSContainerGroupView : UIView

- (id)initWithFrame:(CGRect)frame frontView:(UIView *)frontView;

@property (nonatomic, readonly, retain) UIView *frontView;
@property (nonatomic, retain) HLSContainerGroupView *backGroupView;

@end
