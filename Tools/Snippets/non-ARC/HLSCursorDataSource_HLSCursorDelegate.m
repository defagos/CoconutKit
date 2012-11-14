#pragma mark HLSCursorDataSource protocol implementation

- (NSUInteger)numberOfElementsForCursor:(HLSCursor *)cursor
{

}

- (UIView *)cursor:(HLSCursor *)cursor viewAtIndex:(NSUInteger)index selected:(BOOL)selected
{

}

- (NSString *)cursor:(HLSCursor *)cursor titleAtIndex:(NSUInteger)index
{

}

- (UIFont *)cursor:(HLSCursor *)cursor fontAtIndex:(NSUInteger)index selected:(BOOL)selected
{

}

- (UIColor *)cursor:(HLSCursor *)cursor textColorAtIndex:(NSUInteger)index selected:(BOOL)selected
{

}

- (UIColor *)cursor:(HLSCursor *)cursor shadowColorAtIndex:(NSUInteger)index selected:(BOOL)selected
{

}

- (CGSize)cursor:(HLSCursor *)cursor shadowOffsetAtIndex:(NSUInteger)index selected:(BOOL)selected
{

}

#pragma mark HLSCursorDelegate protocol implementation

- (void)cursor:(HLSCursor *)cursor didMoveFromIndex:(NSUInteger)index
{

}

- (void)cursor:(HLSCursor *)cursor didMoveToIndex:(NSUInteger)index
{

}

- (void)cursorDidStartDragging:(HLSCursor *)cursor
{

}

- (void)cursor:(HLSCursor *)cursor didDragNearIndex:(NSUInteger)index
{

}

- (void)cursorDidStopDragging:(HLSCursor *)cursor
{

}