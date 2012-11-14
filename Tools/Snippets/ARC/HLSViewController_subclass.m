#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        // Code
    }
    return self;
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
}

- (void)releaseViews
{
    [super releaseViews];
    
    // Code
}

#pragma mark Accessors and mutators

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Code
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Code
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
    // Code
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Code
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Code
}

#pragma mark Orientation management

- (NSUInteger)supportedInterfaceOrientations
{   
    // Code, most probably one of:
    // return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskAll;
    // return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait;
    // return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskLandscape;
    // return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark Memory warnings

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Code    
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    // Code
}