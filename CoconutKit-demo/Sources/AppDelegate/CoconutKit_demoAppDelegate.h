//
//  CoconutKit_demoAppDelegate.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

// Forward declarations
@class CoconutKit_demoApplication;

@interface CoconutKit_demoAppDelegate : NSObject <UIApplicationDelegate> {
@private
    CoconutKit_demoApplication *m_application;
    UIWindow *m_window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

