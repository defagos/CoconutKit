//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <UIKit/UIKit.h>

@interface UIViewController (HLSInstantiation)

/**
 * Instantiate a view controller from a storyboard, looking for a storyboard file with the the specified name, containing
 * a view controller with the name of the class or one of its superclasses as identifier (if none is found, the initial
 * view controller is used), and belonging to this class. Lookup is performed in the specified bundle or, if nil, in the 
 * main bundle.
 *
 * If no storyboard name is provided, a storyboard file with the name of the class or one of its superclasses is searched,
 * containing a view controller with this name as identifier, and belonging to the associated class.
 */
- (instancetype)instanceWithStoryboardName:(NSString *)storyboardName inBundle:(NSBundle *)bundle;

/**
 * Instantiate a view controller, looking for a storyboard or a nib in the specified bundle. If no bundle is specified, lookup
 * is performed in the main bundle.
 *
 * Storyboard lookup is performed first with no storyboard name provided (read above how this is achieved). If no match is
 * found, a nib bearing the same name as the class or one of its superclasses is searched instead.
 */
- (instancetype)instanceInBundle:(NSBundle *)bundle;

@end
