//
//  HLSLogger.h
//  nut
//
//  Created by Samuel Défago on 7/14/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Logging macros. Only active if HLS_LOGGER is added to your configuration preprocessor flags (-DHLS_LOGGER)
 */
#ifdef HLS_LOGGER

// Note the ## in front of __VA_ARGS__ to support 0 variable arguments
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
 * Basic logging facility writing to the console. Thread-safe
 *
 * To enable logging, you can use either the release or debug version of this library, the logging code is in both
 * (the linker ensures that you do not pay for it if your do not actually use it). To add logging to your project,
 * use the logging macros above. Those will strip off the logging code for your release builds. Debug builds with
 * logging enabled must be configured as follows:
 *   - in your project target settings, add -DDEBUG to the "Other C flags" parameter. This disables logging code
 *     stripping
 *   - add an environment.plist file to your project, containing the "Logger level" property (set to either
 *     DEBUG, INFO, WARN, ERROR or FATAL). This sets the logging level to use
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
 * Logging functions; should never be called directly, use the macros instead
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
