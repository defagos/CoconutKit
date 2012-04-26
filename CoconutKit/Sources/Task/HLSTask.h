//
//  HLSTask.h
//  CoconutKit
//
//  Created by Samuel Défago on 12/17/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSProgressTracker.h"

// Forward declarations
@class HLSTaskGroup;
@protocol HLSTaskDelegate;

/**
 * Abstract class for tasks. Tasks offer a delegate mechanism for tracking their status. To create your own
 * tasks, simply subclass HLSTask and override the operationClass method to return the class of the operation
 * responsible for processing the task.
 *
 * A task must not be submitted several times simultaneously (this leads to undefined behavior). A task
 * which was fully processed can be submitted again (and with another delegate if needed), but only when it
 * is not running anymore.
 *
 * Designated initializer: init
 */
@interface HLSTask : NSObject {
@private
    NSString *_tag;
    NSDictionary *_userInfo;
    BOOL _running;
    BOOL _finished;
    BOOL _cancelled;
    HLSProgressTracker *_progressTracker;
    NSDictionary *_returnInfo;
    NSError *_error;
    HLSTaskGroup *_taskGroup;               // parent task group if any, nil if none
}

/**
 * Class responsible of processing the task. Must be a subclass of HLSTaskOperation
 * Must be overridden
 */
- (Class)operationClass;

/**
 * Optional tag to identify a task
 * Not meant to be overridden
 */
@property (nonatomic, retain) NSString *tag;

/**
 * Dictionary which can be used freely to convey additional information
 * Not meant to be overridden
 */
@property (nonatomic, retain) NSDictionary *userInfo;

/**
 * Return YES if the task processing is running
 * Not meant to be overridden
 */
@property (nonatomic, readonly, assign, getter=isRunning) BOOL running;

/**
 * Return YES if the task processing is over (this can be because the operation has completed its task,
 * successfully or not, or after it has been cancelled)
 */
@property (nonatomic, readonly, assign, getter=isFinished) BOOL finished;

/**
 * Return YES if the task group has been cancelled
 */
@property (nonatomic, readonly, assign, getter=isCancelled) BOOL cancelled;

/**
 * Task progress tracker. The progress value always reaches 1.f when a task ends (whether it finishes successfully, 
 * encounters an error, or is cancelled)
 *
 * Not meant to be overridden
 */
- (id<HLSProgressTracker>)progressTrackerInfo;

/**
 * NSDictionary which can freely be used to convey return information
 * Not meant to be overridden
 */
@property (nonatomic, readonly, retain) NSDictionary *returnInfo;

/**
 * When the process is complete, check this property to find out if an error was encountered
 * Not meant to be overridden
 */
@property (nonatomic, readonly, retain) NSError *error;

@end

@protocol HLSTaskDelegate <NSObject>
@optional

/**
 * The task has started processing
 */
- (void)taskDidStart:(HLSTask *)task;

/**
 * The task is being processed and has an updated status (you can call -progress to get its completion 
 * status)
 */
- (void)taskDidProgress:(HLSTask *)task;

/**
 * The task has been fully processed. Check the error property to find if the processing was successful or 
 * not (and why)
 */
- (void)taskDidFinish:(HLSTask *)task;

/**
 * The task has been cancelled. Usually you wouldn't expect the need for delegate method to be called when 
 * a cancel request occurs, because cancel operations are executed on the spot. With tasks, however, the 
 * exact time at which a task operation  ends after a cancel has been requested depends on the operation 
 * implementation itself. We thus cannot assume that an operation has ended right after a cancel has been 
 * sent, thus the need for a dedicated delegate method
 */
- (void)taskDidCancel:(HLSTask *)task;

@end
