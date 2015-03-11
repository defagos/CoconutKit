//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <UIKit/UIKit.h>

@interface HLSCollectionViewController : UICollectionViewController

- (instancetype)initWithStoryboardName:(NSString *)storyboardName bundle:(NSBundle *)bundle NS_REQUIRES_SUPER;

- (instancetype)initWithBundle:(NSBundle *)bundle NS_REQUIRES_SUPER;

@end
