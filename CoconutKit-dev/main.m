//
//  main.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 3/3/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) 
{    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool drain];
    return retVal;
}
