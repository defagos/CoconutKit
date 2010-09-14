//
//  HLSDownloaderTools.m
//  nut
//
//  Created by Samuel Défago on 8/18/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSDownloaderTools.h"

@implementation HLSDownloaderTools

+ (UIImage *)imageFromDownloaderData:(NSData *)data 
                       busyImageName:(NSString *)busyImageName
                    failureImageName:(NSString *)failureImageName
{
    // If nil, no downloader object or still downloading; busy fetching image
    if (! data) {
        return [UIImage imageNamed:busyImageName];
    }
    
    // Try to convert as image; if failed, then invalid data
    UIImage *image = [UIImage imageWithData:data];
    if (image) {
        return image;
    }
    else {
        return [UIImage imageNamed:failureImageName];
    }
}

@end
