//
//  HLSDownloaderTools.h
//  nut
//
//  Created by Samuel Défago on 8/18/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Some tools for use with Downloaded data
 */
@interface HLSDownloaderTools : NSObject {
@private
    
}

/**
 * Converts the NSData downloaded by an HLSDownloader object into an image. If successful, the image is returned.
 * While the download is in progress, the specified busy image is returned. If the downloaded data is not
 * an image, then the specified failure image is returned
 */
+ (UIImage *)imageFromDownloaderData:(NSData *)data 
                       busyImageName:(NSString *)busyImageName
                    failureImageName:(NSString *)failureImageName;

@end
