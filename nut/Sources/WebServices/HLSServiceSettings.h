//
//  HLSServiceSettings.h
//  nut
//
//  Created by Samuel Défago on 7/31/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Collect all settings for configuring a web service broker. If your specific web service needs some additional
 * parameters (e.g. a login / password for establishing an authenticated connection first), just derive from
 * this class.
 *
 * Designated initializer: initWithURL:requesterClassName:aggregatorClassName:decoderClassName
 */
@interface HLSServiceSettings : NSObject {
@private
    NSURL *m_url;
    NSString *m_requesterClassName;
    NSString *m_aggregatorClassName;
    NSString *m_decoderClassName;
}

- (id)initWithURL:(NSURL *)url
requesterClassName:(NSString *)requesterClassName
aggregatorClassName:(NSString *)aggregatorClassName
 decoderClassName:(NSString *)decoderClassName;

@property (nonatomic, readonly, copy) NSURL *url;
@property (nonatomic, readonly, retain) NSString *requesterClassName;
@property (nonatomic, readonly, retain) NSString *aggregatorClassName;
@property (nonatomic, readonly, retain) NSString *decoderClassName;

@end
