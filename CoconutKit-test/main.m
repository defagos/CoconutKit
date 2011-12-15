//
//  main.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 16.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

HLSEnableNSManagedObjectValidation()

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"GHUnitIOSAppDelegate");
    [pool release];
    return retVal;
}
