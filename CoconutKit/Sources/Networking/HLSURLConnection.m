//
//  HLSURLConnection.m
//  CoconutKit
//
//  Created by Samuel Défago on 12/6/12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "HLSURLConnection.h"

#import "HLSLogger.h"

@interface HLSURLConnection ()

@property (nonatomic, strong) NSURLRequest *request;

@end

@implementation HLSURLConnection

#pragma mark Object creation and destruction

- (instancetype)initWithRequest:(NSURLRequest *)request completionBlock:(HLSConnectionCompletionBlock)completionBlock
{
    if (self = [super initWithCompletionBlock:completionBlock]) {
        if (! request) {
            HLSLoggerError(@"Missing request");
            return nil;
        }
        
        self.request = request;
    }
    return self;
}

- (instancetype)initWithCompletionBlock:(HLSConnectionCompletionBlock)completionBlock
{
    return nil;
}

@end
