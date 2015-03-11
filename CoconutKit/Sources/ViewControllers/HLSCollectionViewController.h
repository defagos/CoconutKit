//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <UIKit/UIKit.h>

/**
 * Provide the same storyboard and nib instantiation abilities as HLSViewController, but for UICollectionViewController
 * subclasses
 */
@interface HLSCollectionViewController : UICollectionViewController

/**
 * Refer to the corresponding HLSViewController documentation
 */
- (instancetype)initWithStoryboardName:(NSString *)storyboardName bundle:(NSBundle *)bundle NS_REQUIRES_SUPER;
- (instancetype)initWithBundle:(NSBundle *)bundle NS_REQUIRES_SUPER;

@end
