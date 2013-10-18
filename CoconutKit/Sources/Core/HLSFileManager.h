//
//  HLSFileManager.h
//  CoconutKit
//
//  Created by Samuel Défago on 12/13/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * Concrete subclasses of HLSFileManager must implement the set of methods declared by the following protocol
 */
@protocol HLSFileManagerAbstract <NSObject>
@optional

/**
 * Return the content of the file at the given location
 */
- (NSData *)contentsOfFileAtPath:(NSString *)path error:(NSError **)pError;

/**
 * Create a file with the specified content at the given location
 *
 * Return YES iff successful
 */
- (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)contents error:(NSError **)pError;

/**
 * Create a directory at the specified path (create intermediate directories if enabled, otherwise fails if the parent directory does not
 * exist)
 *
 * Return YES iff successful
 */
- (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)withIntermediateDirectories error:(NSError **)pError;

/**
 * List the contents of the specified directory
 */
- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)pError;

/**
 * Return YES iff the file or folder exists at the specified path (and whether it is a directory or not; you can pass NULL if you do not
 * need this information)
 */
- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)pIsDirectory;

/**
 * Copy the file or directory at the specified path to a new location
 *
 * Return YES iff successful
 */
- (BOOL)copyItemAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError **)pError;

/**
 * Move the file or directory at the specified path to a new location
 *
 * Return YES iff successful
 */
- (BOOL)moveItemAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError **)pError;

/**
 * Remove the file or directory at the specified path
 *
 * Return YES iff successful
 */
- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)pError;

@end

/**
 * Concrete subclasses of HLSFileManager can implement the set of methods declared by the following protocol if they
 * support streams. Check providingInputStreams and providingOutputStreams before calling any of them on a file manager
 * instance
 */
@protocol HLSFileManagerStreamSupport <NSObject>
@optional

/**
 * Return an input stream for the file at a given location, nil if the path is invalid
 */
- (NSInputStream *)inputStreamWithFileAtPath:(NSString *)path;

/**
 * Return an output stream for the file at a given location
 */
- (NSOutputStream *)outputStreamToFileAtPath:(NSString *)path append:(BOOL)append;

@end

/**
 * Concrete subclasses of HLSFileManager can implement the set of methods declared by the following protocol if they
 * support URLs. Check providingURLs before calling any of them on a file manager instance
 */
@protocol HLSFileManagerURLSupport <NSObject>
@optional

/**
 * Return the file URL pointing at the file path
 */
- (NSURL *)URLForFileAtPath:(NSString *)path;

@end

/**
 * Abstract class for file operations. Subclass and implement methods from the HLSFileManagerAbstract protocol to create
 * your own concrete file management classes. Subclasses should be implemented in a thread-safe manner.
 *
 * For all methods, paths represent locations relative to the managed storage, and should be given using the standard
 * notation /path/to/some/file.txt. The / at the beginning represents the storage root
 *
 * Designated initializer: -init
 */
@interface HLSFileManager : NSObject <HLSFileManagerAbstract, HLSFileManagerStreamSupport, HLSFileManagerURLSupport>

/**
 * Return YES iff the file or folder exists at the specified path
 */
- (BOOL)fileExistsAtPath:(NSString *)path;

/**
 * Return YES iff the corresponding stream type is supported. Check before calling methods from the HLSFileManagerStreamSupport
 * protocol
 */
@property (atomic, readonly, assign, getter=isProvidingInputStreams) BOOL providingInputStreams;
@property (atomic, readonly, assign, getter=isProvidingInputStreams) BOOL providingOutputStreams;

/**
 * Return YES iff URL mappings are supported. Check before calling methods from the HLSFileManagerURLSupport protocol
 */
@property (atomic, readonly, assign, getter=isProvidingURLs) BOOL providingURLs;

@end
