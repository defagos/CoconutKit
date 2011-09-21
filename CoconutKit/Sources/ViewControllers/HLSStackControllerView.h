//
//  HLSStackControllerView.h
//  CoconutKit
//
//  Created by Samuel Défago on 21.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Private class for use by HLSStackController implementation
 *
 * A stack is a container which must fill the whole space available, i.e.
 *    - the whole screen if it is added as root view controller
 *    - the view in which it is added as subview if not added as root view controller
 * We therefore need to capture the exact time at which the view is added as subview, which is the sole purpose of
 * this UIView subclass. We should avoid adjusting the frame in HLSStackController viewWillAppear: implementation.
 * There are two reasons:
 *    - the view controller's view frame should be known at this point, and should not be changed anymore
 *    - UIViewController view lifecycle contract does not state whether the view has been added as subview or not when
 *      viewWillAppear: is called. For UINavigationController, for example, this is not the case.
 */
@interface HLSStackControllerView : UIView {
@private
    
}

@end
