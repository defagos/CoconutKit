//
//  HLSServiceSettings.m
//  nut
//
//  Created by Samuel Défago on 7/31/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSServiceSettings.h"

@interface HLSServiceSettings ()

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, retain) NSString *requesterClassName;
@property (nonatomic, retain) NSString *aggregatorClassName;
@property (nonatomic, retain) NSString *decoderClassName;

@end

@implementation HLSServiceSettings

#pragma mark Object creation and destruction

- (id)initWithURL:(NSURL *)url
requesterClassName:(NSString *)requesterClassName
aggregatorClassName:(NSString *)aggregatorClassName
 decoderClassName:(NSString *)decoderClassName;
{
    if (self = [super init]) {
        self.url = url;
        self.requesterClassName = requesterClassName;
        self.aggregatorClassName = aggregatorClassName;
        self.decoderClassName = decoderClassName;
        
    }
    return self;
}

- (void)dealloc
{
    self.url = nil;
    self.requesterClassName = nil;
    self.aggregatorClassName = nil;
    self.decoderClassName = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize url = m_url;

@synthesize requesterClassName = m_requesterClassName;

@synthesize aggregatorClassName = m_aggregatorClassName;

@synthesize decoderClassName = m_decoderClassName;

@end
