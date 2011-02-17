//
//  HLSScrollViewController.h
//  nut
//
//  Created by Samuel Défago on 2/17/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSPlaceholderViewController.h"

/**
 * View controller decorator adding scroll bars to an existing view controller. Simply set the view controller to
 * be displayed as inset using one of the dedicated HLSPlaceholderViewController methods. Note that a scroll view 
 * controller automatically takes the whole space available where it is rendered. You can still render it within
 * an HLSPlaceholderViewController if you want it to occupy some specific portion of a view.
 *
 * This view controller class is not meant to be inherited, only used as a decorator. Properties of the wrapped 
 * view controller (title, navigation items, etc.) are forwarded transparently, so that you can define those 
 * properties in your wrapped view controller and still have navigation controllers behave properly.
 *
 * The reason this view controller has been introduced is that designing large views wrapped in a scroll view
 * is cumbersome. Using Interface Builer is not convenient, and creating it via code is time-consuming. With the help
 * of HLSScrollViewController, we can now design a large view controller completely using Interface Builder, then
 * simply decorate it for display.
 *
 * Designated initializer: init
 */
@interface HLSScrollViewController : HLSPlaceholderViewController {
@private
    
}

@end
