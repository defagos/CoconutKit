//
//  Customer.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/28/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface Customer : NSObject {
@private
    NSString *m_firstName;
    NSString *m_lastName;
    NSString *m_email;
    NSString *m_street;
    NSString *m_city;
    NSString *m_state;
    NSString *m_country;
}

@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *street;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *country;

@end
