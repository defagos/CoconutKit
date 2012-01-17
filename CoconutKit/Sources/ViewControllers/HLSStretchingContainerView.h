//
//  HLSStretchingContainerView.h
//  CoconutKit
//
//  Created by Samuel Défago on 21.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * The are mostly two kinds of container view controllers:
 *   - Those from which one has to inherit to define a layout (e.g. HLSPlaceholderViewController)
 *   - Those which are meant to fill the view they are added to (e.g. UINavigationController, UITabBarController,
 *     HLSStackController), and which are not meant to be subclassed
 * In the latter case, the view controller container manages the creation of its view. The HLSStretchingContainerView
 * class is the perfect class to use when implementing "stretching" containers: An HLSStretchingContainerView namely 
 * adjusts its frame when it is added as subview, so that its frame matches the dimensions of its superview.
 *
 * This class exists because adjusting the frame of a container view controller's view inside its viewWillAppear: method 
 * leads to unpredictable behavior:
 *   - a view controller's view frame (and thus the view of a container view controller) must not be altered anymore 
 *     after viewWillAppear: is called. One of the properties of viewWillAppear: is namely that the final view
 *     controller's view frame is known when it is called
 *   - the UIViewController view lifecycle contract does not state whether the view has been added as subview or not
 *     when viewWillAppear: is called. For UINavigationController, this is for example not the case
 *
 * You should instantiate HLSStretchingContainerView using -init
 *
 * Designated initializer: initWithFrame:
 */
@interface HLSStretchingContainerView : UIView {
@private
    
}

@end
