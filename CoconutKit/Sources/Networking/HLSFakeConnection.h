//
//  HLSFakeConnection.h
//  CoconutKit
//
//  Created by Samuel Défago on 08.04.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSConnection.h"

@interface HLSFakeConnection : HLSConnection

- (id)initWithResponseObject:(id)responseObject error:(NSError *)error completionBlock:(HLSConnectionCompletionBlock)completionBlock;

@end
