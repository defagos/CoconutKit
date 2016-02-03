//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

/**
 * Thin wrapper to provide for store weak references in associated objects (see HLSRuntime.m)
 *
 * Borrowed from http://stackoverflow.com/questions/16569840/using-objc-setassociatedobject-with-weak-references/27035233#27035233
 */
@interface HLSWeakObjectWrapper : NSObject

- (id)initWithObject:(id)object;

@property (nonatomic, readonly, weak) id object;

@end
