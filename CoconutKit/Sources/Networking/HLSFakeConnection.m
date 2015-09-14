//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSFakeConnection.h"

#import "HLSCoreError.h"
#import "NSBundle+HLSExtensions.h"
#import "NSError+HLSExtensions.h"

@interface HLSFakeConnection ()

@property (nonatomic, strong) id fakeResponseObject;
@property (nonatomic, strong) NSError *fakeError;

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
    NSError *error = [NSError errorWithDomain:HLSCoreErrorDomain
                                         code:HLSCoreErrorCanceled
                         localizedDescription:CoconutKitLocalizedString(@"The connection has been canceled", nil)];
    [self finishWithResponseObject:nil error:error];
}

@end
