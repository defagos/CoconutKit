//
//  HLSLogger.m
//  CoconutKit
//
//  Created by Samuel Défago on 7/14/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSLogger.h"

#pragma mark -
#pragma mark HLSLoggerMode struct

typedef struct {
	NSString *name;                 // Mode name
	HLSLoggerLevel level;           // Corresponding level
    NSString *rgbValues;            // RGB values for XcodeColors
} HLSLoggerMode;

static const HLSLoggerMode kLoggerModeDebug = {@"DEBUG", 0, nil};
static const HLSLoggerMode kLoggerModeInfo = {@"INFO", 1, nil};
static const HLSLoggerMode kLoggerModeWarn = {@"WARN", 2, @"255,120,0"};
static const HLSLoggerMode kLoggerModeError = {@"ERROR", 3, @"255,0,0"};
static const HLSLoggerMode kLoggerModeFatal = {@"FATAL", 4, @"255,0,0"};

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
                if ([levelName isEqualToString:kLoggerModeDebug.name]) {
                    level = HLSLoggerLevelDebug;
                }
                else if ([levelName isEqualToString:kLoggerModeInfo.name]) {
                    level = HLSLoggerLevelInfo;		
                }
                else if ([levelName isEqualToString:kLoggerModeWarn.name]) {
                    level = HLSLoggerLevelWarn;
                }
                else if ([levelName isEqualToString:kLoggerModeError.name]) {
                    level = HLSLoggerLevelError;
                }
                else if ([levelName isEqualToString:kLoggerModeFatal.name]) {
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

    static BOOL s_configurationLoaded = NO;
    static BOOL s_xcodeColorsEnabled = NO;
    if (! s_configurationLoaded) {
        NSString *xcodeColorsValue = [[[NSProcessInfo processInfo] environment] objectForKey:@"XcodeColors"];
        s_xcodeColorsEnabled = [xcodeColorsValue isEqualToString:@"YES"];
        s_configurationLoaded = YES;
    }
    
    // NSLog is thread-safe
    NSString *fullLogEntry = [NSString stringWithFormat:@"[%@] %@", mode.name, message];
    if (s_xcodeColorsEnabled && mode.rgbValues) {
        NSLog(@"\033[fg%@;%@\033[;", mode.rgbValues, fullLogEntry);
    }
    else {
        NSLog(@"%@", fullLogEntry);
    }
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
