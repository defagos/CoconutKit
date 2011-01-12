//
//  HLSTask.m
//  Funds_iPad
//
//  Created by Samuel Défago on 12/17/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSTask.h"

#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSTaskGroup.h"

@interface HLSTask ()

@property (nonatomic, assign, getter=isRunning) BOOL running;
@property (nonatomic, assign, getter=isFinished) BOOL finished;
@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;
@property (nonatomic, assign) float progress;
@property (nonatomic, retain) NSDictionary *returnInfo;
@property (nonatomic, retain) NSError *error;
@property (nonatomic, assign) HLSTaskGroup *taskGroup;           // weak ref to parent task group

@end

@implementation HLSTask

#pragma mark -
#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)dealloc
{
    self.tag = nil;
    self.userInfo = nil;
    self.returnInfo = nil;
    self.error = nil;
    self.taskGroup = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors and mutators

- (Class)operationClass
{
    logger_error(@"No operation class attached to task class %@", [self class]);
    return NULL;
}

@synthesize tag = _tag;

@synthesize userInfo = _userInfo;

@synthesize running = _running;

@synthesize finished = _finished;

@synthesize cancelled = _cancelled;

@synthesize progress = _progress;

- (void)setProgress:(float)progress
{
    // If the value has not changed, nothing to do
    if (floateq(progress, _progress)) {
        return;
    }
    
    // Sanitize input
    if (floatlt(progress, 0.f) || floatgt(progress, 1.f)) {
        if (floatlt(progress, 0.f)) {
            _progress = 0.f;
        }
        else {
            _progress = 1.f;
        }
        logger_warn(@"Incorrect value %f for progress value, must be between 0 and 1. Fixed", progress);
    }
    else {
        _progress = progress;
    }
}

@synthesize returnInfo = _returnInfo;

@synthesize error = _error;

@synthesize taskGroup = _taskGroup;

#pragma mark -
#pragma mark Resetting

- (void)reset
{
    self.running = NO;
    self.finished = NO;
    self.cancelled = NO;
    self.progress = 0.f;
    self.returnInfo = nil;
    self.error = nil;
}

@end
