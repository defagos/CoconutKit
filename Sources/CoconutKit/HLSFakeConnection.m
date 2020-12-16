//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSFakeConnection.h"

#import "NSBundle+HLSExtensions.h"
#import "NSBundle+HLSDynamicLocalization.h"
#import "NSError+HLSExtensions.h"

@interface HLSFakeConnection ()

@property (nonatomic) id fakeResponseObject;
@property (nonatomic) NSError *fakeError;

@end

@implementation HLSFakeConnection

#pragma mark Object creation and destruction

- (instancetype)initWithResponseObject:(id)responseObject error:(NSError *)error completionBlock:(HLSConnectionCompletionBlock)completionBlock
{
    if (self = [super initWithCompletionBlock:completionBlock]) {
        self.fakeResponseObject = responseObject;
        self.fakeError = error;
    }
    return self;
}

- (instancetype)initWithCompletionBlock:(HLSConnectionCompletionBlock)completionBlock
{
    return [self initWithResponseObject:nil error:nil completionBlock:completionBlock];
}

- (instancetype)init
{
    return [self initWithCompletionBlock:nil];
}

#pragma mark HLSConnectionAbstract protocol implementation

- (void)startConnectionWithRunLoopModes:(NSSet *)runLoopModes
{
    [self finishWithResponseObject:self.fakeResponseObject error:self.fakeError];
}

- (void)cancelConnection
{
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                         code:NSURLErrorCancelled
                         localizedDescription:HLSLocalizedDescriptionForCFNetworkError(NSURLErrorCancelled)];
    [self finishWithResponseObject:nil error:error];
}

@end
