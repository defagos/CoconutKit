#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        // Code
    }
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
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

#pragma mark View customisation

- (void)awakeFromNib
{

}