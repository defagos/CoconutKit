//
//  HLSViewPlaceholder.h
//  nut
//
//  Created by Samuel Défago on 9/28/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Protocol implemented by views exhibiting a placeholder view for view composition
 */
@protocol HLSViewPlaceholder <NSObject>
@required
@property (nonatomic, retain) IBOutlet UIView *placeholderView;

@end
