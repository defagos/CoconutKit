//
//  HLSErrorTemplate.h
//  nut
//
//  Created by Samuel Défago on 04.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * An internal class for defining default properties associated with an error
 *
 * Designated initializer: initWithCode:domain:
 */
@interface HLSErrorTemplate : NSObject {
@private
    NSInteger m_code;
    NSString *m_domain;
    NSString *m_localizedDescription;
    NSString *m_localizedFailureReason;
    NSString *m_localizedRecoverySuggestion;
    NSArray *m_localizedRecoveryOptions;
    id m_recoveryAttempter;
    NSString *m_helpAnchor;
}

- (id)initWithCode:(NSInteger)code domain:(NSString *)domain;

@property (nonatomic, readonly, assign) NSInteger code;
@property (nonatomic, readonly, retain) NSString *domain;
@property (nonatomic, retain) NSString *localizedDescription;
@property (nonatomic, retain) NSString *localizedFailureReason;
@property (nonatomic, retain) NSString *localizedRecoverySuggestion;
@property (nonatomic, retain) NSArray *localizedRecoveryOptions;
@property (nonatomic, retain) id recoveryAttempter;
@property (nonatomic, retain) NSString *helpAnchor;

@end
