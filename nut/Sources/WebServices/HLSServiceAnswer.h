//
//  HLSServiceAnswer.h
//  nut
//
//  Created by Samuel Défago on 7/31/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Designated initializer: initWithId:
 */
@interface HLSServiceAnswer : NSObject {
@private
    NSString *m_body;
    NSString *m_requestId;
}

- (id)initWithBody:(NSString *)body forRequestId:(NSString *)requestId;

@property (nonatomic, copy, readonly) NSString *body;
@property (nonatomic, copy, readonly) NSString *requestId;

@end
