//
//  nut_demoApplication.h
//  nut-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface nut_demoApplication : NSObject {
@private
    UINavigationController *m_navigationController;
}

- (UIViewController *)viewController;

@end
