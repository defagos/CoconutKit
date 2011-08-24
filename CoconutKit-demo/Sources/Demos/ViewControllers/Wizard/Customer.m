//
//  Customer.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/28/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "Customer.h"

@implementation Customer

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.firstName = nil;
    self.lastName = nil;
    self.email = nil;
    self.street = nil;
    self.city = nil;
    self.state = nil;
    self.country = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize firstName = m_firstName;

@synthesize lastName = m_lastName;

@synthesize email = m_email;

@synthesize street = m_street;

@synthesize city = m_city;

@synthesize state = m_state;

@synthesize country = m_country;

@end
