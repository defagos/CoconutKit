#pragma mark Non-trivial default values for new records

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    // Code
}

#pragma mark Accessors and mutators

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; field1: %@; field2: %@>", 
            [self class],
            self,
            field1,
            field2];
}