//
//  MAWeakDictionary.m
//  ZeroingWeakRef
//
//  Created by Mike Ash on 7/13/10.
//

#import "MAWeakDictionary.h"

#import "MAZeroingWeakRef.h"


@implementation MAWeakDictionary

- (id)init
{
    if((self = [super init]))
    {
        _dict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_dict release];
    [super dealloc];
}

- (NSUInteger)count
{
    return [_dict count];
}

- (id)objectForKey: (id)aKey
{
    MAZeroingWeakRef *ref = [_dict objectForKey: aKey];
    id obj = [ref target];
    
    // clean out keys whose objects have gone away
    if(ref && !obj)
        [_dict removeObjectForKey: aKey];
    
    return obj;
}

- (NSEnumerator *)keyEnumerator
{
    // enumerate over a copy because -objectForKey: mutates
    // which could cause an exception in code that should
    // appear to be correct
    return [[_dict allKeys] objectEnumerator];
}

- (void)removeObjectForKey: (id)aKey
{
    [_dict removeObjectForKey: aKey];
}

- (void)setObject: (id)anObject forKey: (id)aKey
{
    [_dict setObject: [MAZeroingWeakRef refWithTarget: anObject]
                                               forKey: aKey];
}

@end
