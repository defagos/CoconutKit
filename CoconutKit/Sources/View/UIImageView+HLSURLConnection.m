//
//  UIImageView+HLSURLConnection.m
//  CoconutKit
//
//  Created by Samuel Défago on 11.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UIImageView+HLSURLConnection.h"

#import <objc/runtime.h>

// Associated object keys
static void *s_connectionKey = &s_connectionKey;

@implementation UIImageView (HLSURLConnection)

- (void)loadWithImageRequest:(NSURLRequest *)request
{
    HLSURLConnection *connection = objc_getAssociatedObject(self, s_connectionKey);
    if (connection) {
        [connection cancel];
    }
    connection = [HLSURLConnection connectionWithRequest:request];
    connection.delegate = self;
    objc_setAssociatedObject(self, s_connectionKey, connection, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Scheduled with the NSRunLoopCommonModes run loop mode to allow connection events (i.e. image assignment when
    // the download is complete) when scrolling occurs (which is quite common when image views are used within
    // table view cells)
    [connection startWithRunLoopMode:NSRunLoopCommonModes];
    
    // TODO: Customizable placeholder view / image
    self.image = nil;
}
                             
- (void)loadWithImageAtURL:(NSURL *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self loadWithImageRequest:request];
}

- (void)connectionDidFinishLoading:(HLSURLConnection *)connection
{
    UIImage *image = [UIImage imageWithData:[connection data]];
    self.image = image;
}

- (void)connection:(HLSURLConnection *)connection didFailWithError:(NSError *)error
{
    // TODO: Customizable placeholder image
    self.image = nil;
}

@end
