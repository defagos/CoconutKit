//
//  HLSFakeConnection.m
//  CoconutKit
//
//  Created by Samuel Défago on 08.04.13.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "HLSFakeConnection.h"

@interface HLSFakeConnection ()

@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSError *error;

@end

@implementation HLSFakeConnection

#pragma mark Object creation and destruction

- (instancetype)initWithResponseObject:(id)responseObject error:(NSError *)error completionBlock:(HLSConnectionCompletionBlock)completionBlock
{
    if (self = [super initWithCompletionBlock:completionBlock]) {
        self.responseObject = responseObject;
        self.error = error;
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
    self.completionBlock ? self.completionBlock(self, self.responseObject, self.error) : nil;
}

- (void)cancelConnection
{}

@end
