//
//  UICollectionView+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 04.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIView+HLSViewBindingImplementation.h"

/**
 * UICollectionView does not support bindings
 */
@interface UICollectionView (HLSViewBinding) <HLSViewBindingImplementation>

@end
