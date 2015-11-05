//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
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
    NSParameterAssert(request);
    
    if (self = [super initWithCompletionBlock:completionBlock]) {
        self.request = request;
    }
    return self;
}

- (instancetype)initWithCompletionBlock:(HLSConnectionCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
