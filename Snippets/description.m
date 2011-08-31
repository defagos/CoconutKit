#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; field1: %@; field2: %@>", 
            [self class],
            self,
            field1
            field2];
}