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
    HLSURLConnection *connection = [HLSURLConnection connectionWithRequest:request];
    connection.delegate = self;
    objc_setAssociatedObject(self, s_connectionKey, connection, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [connection start];
    
    // TODO: Customizable placeholder view / image
    self.image = nil;
}
                             
- (void)loadWithImageAtURL:(NSURL *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self loadWithImageRequest:request];
}

- (void)connectionDidFinish:(HLSURLConnection *)connection
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
