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

static const HLSLoggerMode kLoggerModeDebug = {@"DEBUG", 0};
static const HLSLoggerMode kLoggerModeInfo = {@"INFO", 1};
static const HLSLoggerMode kLoggerModeWarn = {@"WARN", 2};
static const HLSLoggerMode kLoggerModeError = {@"ERROR", 3};
static const HLSLoggerMode kLoggerModeFatal = {@"FATAL", 4};

#pragma mark -
#pragma mark HLSLogger class

@interface HLSLogger ()

- (void)logMessage:(NSString *)message forMode:(HLSLoggerMode)mode;

@end

@implementation HLSLogger

#pragma mark Class methods

+ (HLSLogger *)sharedLogger
{
	static HLSLogger *s_instance = nil;
	
    // Double-checked locking pattern
	if (! s_instance) {
        @synchronized(self) {
            if (! s_instance) {
                // Read the main .plist file content
                NSDictionary *infoProperties = [[NSBundle mainBundle] infoDictionary];
                
                // Create a logger with the corresponding level
                NSString *levelName = [infoProperties valueForKey:@"HLSLoggerLevel"];
                HLSLoggerLevel level;
                if ([levelName isEqual:kLoggerModeDebug.name]) {
                    level = HLSLoggerLevelDebug;
                }
                else if ([levelName isEqual:kLoggerModeInfo.name]) {
                    level = HLSLoggerLevelInfo;		
                }
                else if ([levelName isEqual:kLoggerModeWarn.name]) {
                    level = HLSLoggerLevelWarn;
                }
                else if ([levelName isEqual:kLoggerModeError.name]) {
                    level = HLSLoggerLevelError;
                }
                else if ([levelName isEqual:kLoggerModeFatal.name]) {
                    level = HLSLoggerLevelFatal;
                }
                else {
                    level = HLSLoggerLevelNone;
                }
                s_instance = [[HLSLogger alloc] initWithLevel:level];                
            }
        }
	}
	return s_instance;
}

#pragma mark Object creation and destruction

- (id)initWithLevel:(HLSLoggerLevel)level
{
	if ((self = [super init])) {
		m_level = level;
	}
	return self;
}

- (id)init
{
	return [self initWithLevel:HLSLoggerLevelNone];
}

#pragma mark Logging methods

- (void)logMessage:(NSString *)message forMode:(HLSLoggerMode)mode
{
	if (m_level > mode.level) {
		return;
	}
	
	NSString *fullLogEntry = [NSString stringWithFormat:@"[%@] %@", mode.name, message];
    
    // NSLog is thread-safe
	NSLog(@"%@", fullLogEntry);
}

- (void)debug:(NSString *)message
{
	[self logMessage:message forMode:kLoggerModeDebug];
}

- (void)info:(NSString *)message
{
	[self logMessage:message forMode:kLoggerModeInfo];
}

- (void)warn:(NSString *)message
{
	[self logMessage:message forMode:kLoggerModeWarn];
}

- (void)error:(NSString *)message
{
	[self logMessage:message forMode:kLoggerModeError];
}

- (void)fatal:(NSString *)message
{
	[self logMessage:message forMode:kLoggerModeFatal];
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
