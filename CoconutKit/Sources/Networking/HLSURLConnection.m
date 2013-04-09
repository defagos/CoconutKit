//
//  HLSURLConnection.m
//  CoconutKit
//
//  Created by Samuel Défago on 12/6/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSURLConnection.h"

#import "HLSAssert.h"
#import "HLSLogger.h"

@interface HLSURLConnection ()

@property (nonatomic, strong) NSURLRequest *request;

@end

@implementation HLSURLConnection

#pragma mark Object creation and destruction

- (id)initWithRequest:(NSURLRequest *)request completionBlock:(HLSConnectionCompletionBlock)completionBlock
{
    if ((self = [super initWithCompletionBlock:completionBlock])) {
        if (! request) {
            HLSLoggerError(@"Missing request");
            return nil;
        }
        
        self.request = request;
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

@end
