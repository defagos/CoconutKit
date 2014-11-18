//
//  MANotificationCenterAdditions.m
//  ZeroingWeakRef
//
//  Created by Michael Ash on 7/12/10.
//

#import "HLSMANotificationCenterAdditions.h"

#import "HLSMAZeroingWeakRef.h"


@implementation NSNotificationCenter (MAZeroingWeakRefAdditions)

- (id)hls_addWeakObserver: (id)observer selector: (SEL)selector name: (NSString *)name object: (id)object
{
    HLSMAZeroingWeakRef *ref = [[HLSMAZeroingWeakRef alloc] initWithTarget: observer];
    
    id noteObj = [self addObserverForName: name object:object queue: nil usingBlock: ^(NSNotification *note) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        id observer = [ref target];
        [observer performSelector: selector withObject: note];
        
        [pool release];
    }];
    
    [ref setCleanupBlock: ^(id target) {
        [self removeObserver: noteObj];
        [ref autorelease];
    }];
    
    return noteObj;
}

@end
