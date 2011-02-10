//
//  nut_demoAppDelegate.h
//  nut-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

// Forward declarations
@class nut_demoApplication;

@interface nut_demoAppDelegate : NSObject <UIApplicationDelegate> {
@private
    nut_demoApplication *m_application;
    UIWindow *m_window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

