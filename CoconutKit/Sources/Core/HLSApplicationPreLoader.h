//
//  HLSApplicationPreLoader.h
//  CoconutKit
//
//  Created by Samuel Défago on 02.07.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface HLSApplicationPreLoader : NSObject <UIWebViewDelegate> {
@private
    UIApplication *_application;
}

- (id)initWithApplication:(UIApplication *)application;

- (void)preload;

@end

