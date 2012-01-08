#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super initWithNibName:[self className] bundle:nil])) {
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
    
    [super dealloc];
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Code
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    // Code, most probably one of:
    // return toInterfaceOrientation == UIInterfaceOrientationPortrait;
    // return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    // return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    // return YES;
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