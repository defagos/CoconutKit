//
//  MAWeakDictionary.h
//  ZeroingWeakRef
//
//  Created by Mike Ash on 7/13/10.
//

#import <Foundation/Foundation.h>


@interface HLSMAWeakDictionary : NSMutableDictionary
{
    NSMutableDictionary *_dict;
}

@end
