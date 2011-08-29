#pragma mark Class methods

+ (void)initialize
{
    if (self != [ClassName class]) {
        return;
    }
    
    // Code
}

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        // Code
    }
    return self;
}

- (void)dealloc
{
    // Code
    
    [super dealloc];
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