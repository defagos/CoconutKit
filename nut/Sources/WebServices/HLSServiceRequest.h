//
//  HLSServiceRequest.h
//  nut
//
//  Created by Samuel Défago on 7/30/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Usually your application should provide a factory for generating requests using just some parameters.
 *
 * Designated initializer: initWithBody:
 */
@interface HLSServiceRequest : NSObject {
@private
    NSString *m_id;
    NSString *m_body;
}

- (id)initWithBody:(NSString *)body;

@property (nonatomic, readonly, copy) NSString *id;
@property (nonatomic, readonly, copy) NSString *body;

@end
