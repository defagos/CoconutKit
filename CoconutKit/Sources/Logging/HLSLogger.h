//
//  HLSLogger.h
//  CoconutKit
//
//  Created by Samuel Défago on 7/14/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

/**
 * Logging macros. Only active if HLS_LOGGER is added to your configuration preprocessor flags (-DHLS_LOGGER). You can also use this macro in your
 * own code if you need to enable or disable logging-specific code for some of your configurations
 */
#ifdef HLS_LOGGER

// Note the ## in front of __VA_ARGS__ to support 0 variable arguments
#define HLSLoggerDebug(format, ...)	[[HLSLogger sharedLogger] debug:[NSString stringWithFormat:@"(%s) - %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]]]
#define HLSLoggerInfo(format, ...)	[[HLSLogger sharedLogger] info:[NSString stringWithFormat:@"(%s) - %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]]]
#define HLSLoggerWarn(format, ...)	[[HLSLogger sharedLogger] warn:[NSString stringWithFormat:@"(%s) - %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]]]
#define HLSLoggerError(format, ...)	[[HLSLogger sharedLogger] error:[NSString stringWithFormat:@"(%s) - %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]]]
#define HLSLoggerFatal(format, ...)	[[HLSLogger sharedLogger] fatal:[NSString stringWithFormat:@"(%s) - %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]]]

#else

#define HLSLoggerDebug(format, ...)
#define HLSLoggerInfo(format, ...)
#define HLSLoggerWarn(format, ...)
#define HLSLoggerError(format, ...)
#define HLSLoggerFatal(format, ...)

#endif

/**
 * Logging levels
 */
typedef NS_ENUM(NSInteger, HLSLoggerLevel) {
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
};

/**
 * Basic logging facility writing to the console or to files, and providing an in-app log viewer. Thread-safe
 *
 * To enable logging, you can use either the release or debug version of this library, the logging code exists in both
 * (the linker ensures that you do not pay for it if your do not actually use it). To add logging to your project,
 * use the logging macros above. Those will remove the logging code for your release builds, this is why you must
 * add -DHLS_LOGGER to the "Other C flags" parameter for the target / configuration for which logging must be available.
 * The default logging level is info.
 *
 * HLSLogger supports XcodeColors (see https://github.com/robbiehanson/XcodeColors for the active fork), an Xcode plugin
 * adding colors to the Xcode debugging console. Simply install the plugin and set an environment variable called 
 * 'XcodeColors' to YES to enable it for your project.
 *
 * You should not instantiate an HLSLogger object yourself. Use the singleton class method instead
 */
@interface HLSLogger : NSObject

/**
 * Singleton instance fetcher
 */
+ (instancetype)sharedLogger;

/**
 * The logger level. The default value is HLSLoggerLevelInfo
 */
@property (nonatomic, assign) HLSLoggerLevel level;

/**
 * Enable or disable logging to a file at runtime. The sharedLogger instance logs files in /Library/HLSLogger. The default 
 * value is NO
 */
@property (nonatomic, assign, getter=isFileLoggingEnabled) BOOL fileLoggingEnabled;

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

/**
 * Display a modal window containing log settings and log file history
 */
- (void)showSettings;

@end

@interface HLSLogger (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end
