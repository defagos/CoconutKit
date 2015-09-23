//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <UIKit/UIKit.h>

/**
 * Gesture recognizer invoking the action once on its target for any kind of gesture. This gesture recognizer
 * is recognized along other gesture recognizers and never prevents them
 */
@interface HLSAnyGestureRecognizer : UIGestureRecognizer <UIGestureRecognizerDelegate>
@end
