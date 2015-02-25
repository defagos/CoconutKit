//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
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
