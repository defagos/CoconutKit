//
//  HLSContainerControllerLoader.h
//  nut
//
//  Created by Samuel Défago on 8/17/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * In many cases where containers of view controllers are used, a large number of view controllers might be loaded. 
 * In such cases it is inefficient to load them all at once before showing up the container controller.
 * Instead, some containers might support the HLSContainerControllerLoader for lazily loading view controllers when
 * they are really required. In such cases a loader delegate member should be provided, through which information
 * required by the container controller can be obtained:
 *   - total number of view controllers to display
 *   - view controller at some index
 *   - orientation behavior: Since the container loads view controllers lazily, it cannot test them to get their
 *                           individual orientation behavior (which is often the criterium upon which the container
 *                           decides whether it supports this orientation or not). Instead it must trust the loader
 *                           delegate about which orientations are supported (the container will probably fail to
 *                           load a view controller or return an error if this information was incorrect). Most
 *                           of the time this makes sense since when a large number of view controllers are loaded
 *                           they have the same behavior (and probably stem from the same class)
 * For a small number of view controllers, container controllers probably provide a way to load all view controllers
 * at the beginning. In such cases clients do not need to implement HLSContainerControllerLoader.
 */
@protocol HLSContainerControllerLoader <NSObject>

- (NSUInteger)viewControllerCount;
- (UIViewController *)viewControllerObjectAtIndex:(NSUInteger)index withOrientation:(UIInterfaceOrientation)orientation;
- (BOOL)allViewControllersShouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end
