//
//  HLSLogger.m
//  CoconutKit
//
//  Created by Samuel Défago on 7/14/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

#import "HLSLogger.h"

#import "HLSApplicationInformation.h"
#import "HLSLogger+Friend.h"
#import "HLSLoggerViewController.h"
#import "NSBundle+HLSExtensions.h"
#import "NSString+HLSExtensions.h"
#import <pthread.h>

typedef struct {
	__unsafe_unretained NSString *name;                 // Mode name
	HLSLoggerLevel level;                               // Corresponding level
    __unsafe_unretained NSString *rgbValues;            // RGB values for XcodeColors
} HLSLoggerMode;

static const HLSLoggerMode kLoggerModeDebug = {@"DEBUG", 0, nil};
static const HLSLoggerMode kLoggerModeInfo = {@"INFO", 1, nil};
static const HLSLoggerMode kLoggerModeWarn = {@"WARN", 2, @"255,120,0"};
static const HLSLoggerMode kLoggerModeError = {@"ERROR", 3, @"255,0,0"};
static const HLSLoggerMode kLoggerModeFatal = {@"FATAL", 4, @"255,0,0"};

static NSString * const HLSLoggerLevelKey = @"HLSLoggerLevelKey";
static NSString * const HLSLoggerFileLoggingEnabledKey = @"HLSLoggerFileLoggingEnabledKey";

@interface HLSLogger ()

@property (nonatomic, strong) NSString *logDirectoryPath;
@property (nonatomic, strong) NSFileHandle *logFileHandle;

@end

@implementation HLSLogger

#pragma mark Class methods

+ (instancetype)sharedLogger
{
	static HLSLogger *s_instance = nil;
    static dispatch_once_t s_onceToken;
    
    dispatch_once(&s_onceToken, ^{
        NSString *logDirectoryPath = [HLSApplicationLibraryDirectoryPath() stringByAppendingPathComponent:@"HLSLogger"];
        s_instance = [[[self class] alloc] initWithLogDirectoryPath:logDirectoryPath];
    });
	return s_instance;
}

#pragma mark Object creation and destruction

- (instancetype)initWithLogDirectoryPath:(NSString *)logDirectoryPath
{
	if (self = [super init]) {
        if (! [logDirectoryPath isFilled]) {
            NSLog(@"A log directory is mandatory");
            return nil;
        }
        
        self.logDirectoryPath = logDirectoryPath;
        
        NSNumber *level = [[NSUserDefaults standardUserDefaults] objectForKey:HLSLoggerLevelKey];
        _level = level ? [level integerValue] : HLSLoggerLevelInfo;
        
        NSNumber *fileLoggingEnabled = [[NSUserDefaults standardUserDefaults] objectForKey:HLSLoggerFileLoggingEnabledKey];
        _fileLoggingEnabled = fileLoggingEnabled ? [fileLoggingEnabled integerValue] : NO;
	}
	return self;
}

#pragma mark Accessors and mutators

@synthesize level = _level;

- (HLSLoggerLevel)level
{
    @synchronized(self) {
        return _level;
    }
}

- (void)setLevel:(HLSLoggerLevel)level
{
    @synchronized(self) {
        _level = level;
        
        [[NSUserDefaults standardUserDefaults] setInteger:level forKey:HLSLoggerLevelKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@synthesize fileLoggingEnabled = _fileLoggingEnabled;

- (BOOL)isFileLoggingEnabled
{
    @synchronized(self) {
        return _fileLoggingEnabled;
    }
}

- (void)setFileLoggingEnabled:(BOOL)fileLoggingEnabled
{
    @synchronized(self) {
        _fileLoggingEnabled = fileLoggingEnabled;
        
        [[NSUserDefaults standardUserDefaults] setBool:fileLoggingEnabled forKey:HLSLoggerFileLoggingEnabledKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark Logging methods

- (void)logMessage:(NSString *)message forMode:(HLSLoggerMode)mode
{
	if (self.level > mode.level) {
		return;
	}

    static BOOL s_xcodeColorsEnabled = NO;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        NSString *xcodeColorsValue = [[[NSProcessInfo processInfo] environment] objectForKey:@"XcodeColors"];
        s_xcodeColorsEnabled = [xcodeColorsValue isEqualToString:@"YES"];
    });
    
    // NSLog is thread-safe and adds date, thread and process information in front of each line
    NSString *logEntry = [NSString stringWithFormat:@"[%@] %@", mode.name, message];
    if (s_xcodeColorsEnabled && mode.rgbValues) {
        NSLog(@"\033[fg%@;%@\033[;", mode.rgbValues, logEntry);
    }
    else {
        NSLog(@"%@", logEntry);
    }
    
    if (self.fileLoggingEnabled) {
        [self logToFileWithEntry:logEntry];
    }
}

- (void)logToFileWithEntry:(NSString *)logEntry
{
    @synchronized(self) {
        if (! self.logFileHandle) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            // Stores all logs in an HLSLogger directory of Library
            if (! [fileManager fileExistsAtPath:self.logDirectoryPath]) {
                NSError *error = nil;
                if (! [fileManager createDirectoryAtPath:self.logDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error]) {
                    NSLog(@"Could not create log directory. Reason: %@", error);
                    return;
                }
            }
            
            // File name: BundleName_version_date.log
            static NSDateFormatter *s_dateFormatter = nil;
            static dispatch_once_t s_onceToken;
            dispatch_once(&s_onceToken, ^{
                s_dateFormatter = [[NSDateFormatter alloc] init];
                [s_dateFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
            });
            
            NSString *dateString = [s_dateFormatter stringFromDate:[NSDate date]];
            NSString *bundleName = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] stringByReplacingOccurrencesOfString:@"." withString:@"-"];
            NSString *versionString = [[[NSBundle mainBundle] friendlyVersionNumber] stringByReplacingOccurrencesOfString:@"." withString:@"-"];
            NSString *logFileName = [NSString stringWithFormat:@"%@_%@_%@.txt", bundleName, versionString, dateString];
            NSString *logFilePath = [self.logDirectoryPath stringByAppendingPathComponent:logFileName];
            if (! [fileManager fileExistsAtPath:logFilePath]) {
                if (! [fileManager createFileAtPath:logFilePath contents:nil attributes:nil]) {
                    NSLog(@"Could not create log file");
                    return;
                }
            }
            
            self.logFileHandle = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        }
    
        // Add date, thread and process information, as NSLog does
        static NSDateFormatter *s_dateFormatter = nil;
        static dispatch_once_t s_onceToken;
        dispatch_once(&s_onceToken, ^{
            s_dateFormatter = [[NSDateFormatter alloc] init];
            [s_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        });
        
        mach_port_t threadId = pthread_mach_thread_np(pthread_self());
        NSString *logFileEntry = [NSString stringWithFormat:@"%@ [%x] %@\n",
                                  [s_dateFormatter stringFromDate:[NSDate date]],
                                  threadId,
                                  logEntry];
        [self.logFileHandle writeData:[logFileEntry dataUsingEncoding:NSUTF8StringEncoding]];
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
	return self.level <= HLSLoggerLevelDebug;
}

- (BOOL)isInfo
{
	return self.level <= HLSLoggerLevelInfo;
}

- (BOOL)isWarn
{
	return self.level <= HLSLoggerLevelWarn;
}

- (BOOL)isError
{
	return self.level <= HLSLoggerLevelError;
}

- (BOOL)isFatal
{
	return self.level <= HLSLoggerLevelFatal;
}

#pragma mark Files

- (NSArray *)availableLogFilePaths
{
    @synchronized(self) {
        NSArray *logFileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.logDirectoryPath error:NULL];
        
        // Log files names are sorted in increasing date order
        NSMutableArray *logFilePaths = [NSMutableArray array];
        for (NSString *logFileName in [logFileNames reverseObjectEnumerator]) {
            NSString *logFilePath = [self.logDirectoryPath stringByAppendingPathComponent:logFileName];
            [logFilePaths addObject:logFilePath];
        }
        
        return [NSArray arrayWithArray:logFilePaths];
    }
}

- (void)clearLogs
{
    @synchronized(self) {
        self.logFileHandle = nil;
        
        NSArray *availableLogPaths = [self availableLogFilePaths];
        for (NSString *availableLogPath in availableLogPaths) {
            NSError *error = nil;
            if (! [[NSFileManager defaultManager] removeItemAtPath:availableLogPath error:&error]) {
                NSLog(@"Could not cleanup log file %@. Reason: %@", availableLogPath, error);
            }
        }
    }
}

#pragma mark Log window

- (void)showSettings
{
    HLSLoggerViewController *loggerViewController = [[HLSLoggerViewController alloc] initWithLogger:self];
    UINavigationController *loggerNavigationController = [[UINavigationController alloc] initWithRootViewController:loggerViewController];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (! rootViewController) {
        return;
    }
    [rootViewController presentViewController:loggerNavigationController animated:YES completion:nil];
}

@end
