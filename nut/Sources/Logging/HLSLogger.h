//
//  HLSLogger.h
//  nut
//
//  Created by Samuel Défago on 7/14/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Helper macros (note the ## in front of __VA_ARGS__ to support 0 variable arguments)
 */
#ifdef DEBUG
#define logger_debug(format, ...)	[[HLSLogger sharedLogger] debug:[NSString stringWithFormat:@"(%s) - %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]]]
#define logger_info(format, ...)	[[HLSLogger sharedLogger] info:[NSString stringWithFormat:@"(%s) - %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]]]
#define logger_warn(format, ...)	[[HLSLogger sharedLogger] warn:[NSString stringWithFormat:@"(%s) - %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]]]
#define logger_error(format, ...)	[[HLSLogger sharedLogger] error:[NSString stringWithFormat:@"(%s) - %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]]]
#define logger_fatal(format, ...)	[[HLSLogger sharedLogger] fatal:[NSString stringWithFormat:@"(%s) - %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]]]
#else
#define logger_debug(format, ...)
#define logger_info(format, ...)
#define logger_warn(format, ...)
#define logger_error(format, ...)
#define logger_fatal(format, ...)
#endif

/**
 * Logging levels
 */
typedef enum {
	HLSLoggerLevelEnumBegin = 0,
	// Values
	HLSLoggerLevelAll = HLSLoggerLevelEnumBegin,
	HLSLoggerLevelDebug = HLSLoggerLevelAll,
	HLSLoggerLevelInfo,
	HLSLoggerLevelWarn,
	HLSLoggerLevelError,
	HLSLoggerLevelFatal,
	HLSLoggerLevelNone,
	// End of values
	HLSLoggerLevelEnumEnd = HLSLoggerLevelNone,
    HLSLoggerLevelEnumSize = HLSLoggerLevelEnumEnd - HLSLoggerLevelEnumBegin
} HLSLoggerLevel;

/**
 * Basic logger facility writing to the console. Currently not thread-safe
 *
 * To use a logger, create an environment.plist file and set the "Logger level" property to either
 * DEBUG, INFO, WARN, ERROR or FATAL.
 *
 * Designated initializer: initWithLevel:
 */
@interface HLSLogger : NSObject {
@private
	HLSLoggerLevel m_level;
}

/**
 * Singleton instance fetcher
 */
+ (HLSLogger *)sharedLogger;

- (id)initWithLevel:(HLSLoggerLevel)level;

/**
 * Logging functions
 */
- (void)debug:(NSString *)message;
- (void)info:(NSString *)message;
- (void)warn:(NSString *)message;
- (void)error:(NSString *)message;
- (void)fatal:(NSString *)message;

/**
 * Level testers
 */
- (BOOL)isDebug;
- (BOOL)isInfo;
- (BOOL)isWarn;
- (BOOL)isError;
- (BOOL)isFatal;

@end
