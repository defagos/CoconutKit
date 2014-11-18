//
//  HLSFileManager.h
//  CoconutKit
//
//  Created by Samuel Défago on 12/13/12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

/**
 * Concrete subclasses of HLSFileManager must implement the set of methods declared by the following protocol
 */
@protocol HLSFileManagerAbstract <NSObject>
@optional

/**
 * Return the content of the file at the given location. If the path is incorrect or if the file does not exist, the method
 * must return nil and an error, otherwise YES and no error.
 */
- (NSData *)contentsOfFileAtPath:(NSString *)path error:(NSError *__autoreleasing *)pError;

/**
 * Create a file with the specified content at the given location. If the path is incorrect or if an error is encountered, 
 * the method must return NO and an error, otherwise YES and no error. If the file already exists, its contents must be 
 * replaced, and the method must return YES and no error
 */
- (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)contents error:(NSError *__autoreleasing *)pError;

/**
 * Create a directory at the specified path (create intermediate directories if enabled, otherwise fails if the parent 
 * directory does not exist). If the path is incorrect or if an error is encountered, the method must return NO and an
 * error, otherwise YES and no error. If the directory already exists, the method must return YES and no error
 */
- (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)withIntermediateDirectories error:(NSError *__autoreleasing *)pError;

/**
 * List the contents of the specified directory. If the path is incorrect or if an error is encountered, the method must
 * return nil and an error, otherwise YES and no error. If the directory is empty, the method must return an empty array,
 * not nil
 */
- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)pError;

/**
 * Return YES iff the file or folder exists at the specified path (and whether it is a directory or not; you can pass NULL if you do not
 * need this information). If the path is invalid or if the file does not exist, the method must return NO and leave the boolean received
 * by reference unchanged
 */
- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)pIsDirectory;

/**
 * Recursively copy the file or directory at the specified path to a new location. If any path is invalid, if the copy 
 * fails, if the destination already exists, if the parent destination directory does not exist or if the destination
 * path is a subfolder of the source path (recursion issues), the method must return NO and an error, otherwise YES 
 * and no error. The destination path must contain the name of the file or directory in its new location
 */
- (BOOL)copyItemAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError *__autoreleasing *)pError;

/**
 * Recursively move the file or directory at the specified path to a new location. If any path is invalid, if the move
 * fails, if the destination already exists, if the parent destination directory does not exist or if the destination
 * path is a subfolder of the source path (recursion issues), the method must return NO and an error, otherwise YES and 
 * no error. The destination path must contain the name of the file or directory in its new location
 */
- (BOOL)moveItemAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError *__autoreleasing *)pError;

/**
 * Remove the file or directory at the specified path. If the path is invalid or if an error is encountered, the method
 * must return nil and an error, otherwise YES and no error. If the path is /, all data is erased, but the root itself
 * must not be destroyed
 */
- (BOOL)removeItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)pError;

@end

/**
 * Concrete subclasses of HLSFileManager can implement the set of methods declared by the following protocol if they
 * support streams
 */
@protocol HLSFileManagerStreamSupport <NSObject>
@optional

/**
 * Return an input stream for the file at a given location, nil if the path is invalid. Check the providingInputStreams
 * property before calling this method
 */
- (NSInputStream *)inputStreamWithFileAtPath:(NSString *)path;

/**
 * Return an output stream for the file at a given location, nil if the path is invalid (e.g. corresponds to an existing
 * directory). Check the providingOutputStreams property before calling this method
 */
- (NSOutputStream *)outputStreamToFileAtPath:(NSString *)path append:(BOOL)append;

@end

/**
 * Concrete subclasses of HLSFileManager can implement the set of methods declared by the following protocol if they
 * support URLs
 */
@protocol HLSFileManagerURLSupport <NSObject>
@optional

/**
 * Return the file URL pointing at a file given its path. If the file does not exist, the method must return nil. Check 
 * the providingURLs property before calling this method
 */
- (NSURL *)URLForFileAtPath:(NSString *)path;

@end

/**
 * Abstract class for file operations. Subclass and implement methods from the HLSFileManagerAbstract protocol to create
 * your own concrete file management classes. Subclasses should be implemented in a thread-safe manner.
 *
 * For all methods, paths represent locations relative to the managed storage, and should be given using the standard
 * notation /path/to/some/file.txt. The / at the beginning represents the storage root and is mandatory
 */
@interface HLSFileManager : NSObject <HLSFileManagerAbstract, HLSFileManagerStreamSupport, HLSFileManagerURLSupport>

/**
 * Create a file manager
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

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
