//
//  nut_demoAppDelegate.h
//  nut-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface nut_demoAppDelegate : NSObject <UIApplicationDelegate> {
@private
    UIWindow *m_window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

