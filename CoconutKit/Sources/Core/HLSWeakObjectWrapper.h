//
//  HLSWeakObjectWrapper.h
//  CoconutKit
//
//  Created by Samuel Defago on 21/11/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

/**
 * Thin wrapper to provide for store weak references in associated objects (see HLSRuntime.m)
 *
 * Borrowed from http://stackoverflow.com/questions/16569840/using-objc-setassociatedobject-with-weak-references/27035233#27035233
 */
@interface HLSWeakObjectWrapper : NSObject

- (id)initWithObject:(id)object;

@property (nonatomic, readonly, weak) id object;

@end
