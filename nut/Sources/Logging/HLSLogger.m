//
//  HLSLogger.m
//  nut
//
//  Created by Samuel Défago on 7/14/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSLogger.h"

#pragma mark -
#pragma mark HLSLoggerMode struct

typedef struct {
	NSString *name;
	HLSLoggerLevel level;
} HLSLoggerMode;

HLSLoggerMode MODE_DEBUG = {@"DEBUG", 0};
HLSLoggerMode MODE_INFO = {@"INFO", 1};
HLSLoggerMode MODE_WARN = {@"WARN", 2};
HLSLoggerMode MODE_ERROR = {@"ERROR", 3};
HLSLoggerMode MODE_FATAL = {@"FATAL", 4};

#pragma mark -
#pragma mark HLSLogger class

@interface HLSLogger ()

- (void)logMessage:(NSString *)message forMode:(HLSLoggerMode)mode;

@end

@implementation HLSLogger

#pragma mark Class methods

+ (HLSLogger *)sharedLogger
{
	static HLSLogger *s_instance;
	
	if (! s_instance) {
		// Read the environment.plist file
		NSString *envPlistPath = [[NSBundle mainBundle] pathForResource:@"environment" ofType:@"plist"];
		NSDictionary *envProperties = [[[NSDictionary alloc] initWithContentsOfFile:envPlistPath] 
									   autorelease];
		
		// Create a logger with the corresponding level
		NSString *levelName = [envProperties valueForKey:@"Logger level"];
		HLSLoggerLevel level;
		if ([levelName isEqual:MODE_DEBUG.name]) {
			level = HLSLoggerLevelDebug;
		}
		else if ([levelName isEqual:MODE_INFO.name]) {
			level = HLSLoggerLevelInfo;		
		}
		else if ([levelName isEqual:MODE_WARN.name]) {
			level = HLSLoggerLevelWarn;
		}
		else if ([levelName isEqual:MODE_ERROR.name]) {
			level = HLSLoggerLevelError;
		}
		else if ([levelName isEqual:MODE_FATAL.name]) {
			level = HLSLoggerLevelFatal;
		}
		else {
			level = HLSLoggerLevelNone;
		}
		s_instance = [[HLSLogger alloc] initWithLevel:level];
	}
	return s_instance;
}

#pragma mark Object creation and destruction

- (id)initWithLevel:(HLSLoggerLevel)level
{
	if (self = [super init]) {
		m_level = level;
	}
	return self;
}

- (id)init
{
	return [self initWithLevel:HLSLoggerLevelNone];
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark Logging methods

- (void)logMessage:(NSString *)message forMode:(HLSLoggerMode)mode
{
	if (m_level > mode.level) {
		return;
	}
	
	NSString *fullLogEntry = [NSString stringWithFormat:@"[%@] %@", mode.name, message];
	NSLog(@"%@", fullLogEntry);
}

- (void)debug:(NSString *)message
{
	[self logMessage:message forMode:MODE_DEBUG];
}

- (void)info:(NSString *)message
{
	[self logMessage:message forMode:MODE_INFO];
}

- (void)warn:(NSString *)message
{
	[self logMessage:message forMode:MODE_WARN];
}

- (void)error:(NSString *)message
{
	[self logMessage:message forMode:MODE_ERROR];
}

- (void)fatal:(NSString *)message
{
	[self logMessage:message forMode:MODE_FATAL];
}

#pragma mark Level testers

- (BOOL)isDebug
{
	return m_level <= HLSLoggerLevelDebug;
}

- (BOOL)isInfo
{
	return m_level <= HLSLoggerLevelInfo;
}

- (BOOL)isWarn
{
	return m_level <= HLSLoggerLevelWarn;
}

- (BOOL)isError
{
	return m_level <= HLSLoggerLevelError;
}

- (BOOL)isFatal
{
	return m_level <= HLSLoggerLevelFatal;
}

@end
