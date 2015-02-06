/*
 * Copyright (c) 2013 Adobe Systems Incorporated. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 */
#import "TrafficLightButton.h"

//these are defined in MainMainu.xib file
static const int CLOSE_BUTTON_TAG = 1000;
static const int MINIMIZE_BUTTON_TAG = 1001;
static const int ZOOM_BUTTON_TAG = 1002;

@implementation TrafficLightButton {
    NSImage *_inactive;
    NSImage *_active;
    NSImage *_hover;
    NSImage *_pressed;
    NSImage *_dirtyInactive;
    NSImage *_dirtyActive;
    NSImage *_dirtyHover;
    NSImage *_dirtyPressed;
    BOOL activeState;
    BOOL hoverState;
    BOOL pressedState;
    BOOL dirtyState;
    BOOL closeButton;
}

- (NSImage *) inactive
{
    return _inactive;
}

- (void) setInactive:(NSImage *) aInactive
{
    if (aInactive != _inactive)
    {
        [_inactive release];
        _inactive = [aInactive retain];
    }
}

- (NSImage *) active
{
    return _active;
}

- (void) setActive:(NSImage *) aActive
{
    if (aActive != _active)
    {
        [_active release];
        _active = [aActive retain];
    }
}

- (NSImage *) hover
{
    return _hover;
}

- (void) setHover:(NSImage *) aHover
{
    if (aHover != _hover)
    {
        [_hover release];
        _hover = [aHover retain];
    }
}

- (NSImage *) pressed
{
    return _pressed;
}

- (void) setPressed:(NSImage *) aPressed
{
    if (aPressed != _pressed)
    {
        [_pressed release];
        _pressed = [aPressed retain];
    }
}

- (NSImage *) dirtyInactive
{
    return _dirtyInactive;
}

- (void) setDirtyInactive:(NSImage *) aDirtyInactive
{
    if (aDirtyInactive != _dirtyInactive)
    {
        [_dirtyInactive release];
        _dirtyInactive = [aDirtyInactive retain];
    }
}

- (NSImage *) dirtyActive
{
    return _dirtyActive;
}

- (void) setDirtyActive:(NSImage *) aDirtyActive
{
    if (aDirtyActive != _dirtyActive)
    {
        [_dirtyActive release];
        _dirtyActive = [aDirtyActive retain];
    }
}

- (NSImage *) dirtyHover
{
    return _dirtyHover;
}

- (void) setDirtyHover:(NSImage *) aDirtyHover
{
    if (aDirtyHover != _dirtyHover)
    {
        [_dirtyHover release];
        _dirtyHover = [aDirtyHover retain];
    }
}

- (NSImage *) dirtyPressed
{
    return _dirtyPressed;
}

- (void) setDirtyPressed:(NSImage *) aDirtyPressed
{
    if (aDirtyPressed != _dirtyPressed)
    {
        [_dirtyPressed release];
        _dirtyPressed = [aDirtyPressed retain];
    }
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    NSString* buttonName = nil;
    //the numbers come from the XIB file.
    if ([self tag] == CLOSE_BUTTON_TAG) {
        buttonName = @"close";
        closeButton = TRUE;
    } else if ([self tag] == MINIMIZE_BUTTON_TAG) {
        buttonName = @"minimize";
    } else if ([self tag] == ZOOM_BUTTON_TAG){
        buttonName = @"zoom";
    }
    self.active = [NSImage imageNamed:[NSString stringWithFormat:@"window-%@-active",buttonName]];
    self.inactive = [NSImage imageNamed:[NSString stringWithFormat:@"window-%@-inactive",buttonName]];
    self.hover = [NSImage imageNamed:[NSString stringWithFormat:@"window-%@-hover",buttonName]];
    self.pressed = [NSImage imageNamed:[NSString stringWithFormat:@"window-%@-pressed",buttonName]];
    if (closeButton) {
        self.dirtyActive = [NSImage imageNamed:[NSString stringWithFormat:@"window-%@-dirty-active",buttonName]];
        self.dirtyInactive = [NSImage imageNamed:[NSString stringWithFormat:@"window-%@-dirty-inactive",buttonName]];
        self.dirtyHover = [NSImage imageNamed:[NSString stringWithFormat:@"window-%@-dirty-hover",buttonName]];
        self.dirtyPressed = [NSImage imageNamed:[NSString stringWithFormat:@"window-%@-dirty-pressed",buttonName]];
    }
    
    // assume active
    activeState = YES;
    [self updateButtonStates];
    
    //get notified of state
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateActiveState)
                                                 name:NSWindowDidBecomeMainNotification object:[self window]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateActiveState)
                                                 name:NSWindowDidResignMainNotification object:[self window]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateActiveState)
                                                 name:NSWindowDidBecomeKeyNotification object:[self window]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateActiveState)
                                                 name:NSWindowDidResignKeyNotification object:[self window]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hoverIn:)
                                                 name:@"TrafficLightsMouseEnter"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hoverOut)
                                                 name:@"TrafficLightsMouseExit"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setDocumentEdited)
                                                 name:@"TrafficLightsDirty"
                                               object:nil];
}

- (void)mouseDown:(NSEvent *)theEvent {
    pressedState = YES;
    hoverState = NO;
    
    if (!activeState) {
        [self.window makeKeyAndOrderFront:self];
        [self.window setOrderedIndex:0];
    }
    
    [self updateButtonStates];
}

- (void)mouseUp:(NSEvent *)theEvent {
    pressedState = NO;
    hoverState = YES;
    
    if (closeButton) {
        [[self window] performClose:nil];
        return;
    }
    if ([self tag] == MINIMIZE_BUTTON_TAG) {
        [[self window] performMiniaturize:nil];
        return;
    }
    if ([self tag] == ZOOM_BUTTON_TAG) {
        [[self window] performZoom:nil];
        return;
    }
    
    [self updateButtonStates];
    [super mouseUp:theEvent];
}

- (void)updateActiveState {
    activeState = [self.window isKeyWindow];
    [self updateButtonStates];
}

- (void)setDocumentEdited {
    if (closeButton) {
        dirtyState = [[self window] isDocumentEdited];
    }
    [self updateButtonStates];
}

-(void)updateButtonStates{
    if (self == nil)
        return;
    if (pressedState) {
        if (closeButton && dirtyState) {
            [self setImage:self.dirtyPressed];
        } else {
            [self setImage:self.pressed];
        }
    } else if (activeState) {
        if (hoverState) {
            if (closeButton && dirtyState) {
                [self setImage:self.dirtyHover];
            } else {
                [self setImage:self.hover];
            }
        } else {
            if (closeButton && dirtyState) {
                [self setImage:self.dirtyActive];
            } else {
                [self setImage:self.active];
            }
        }
    } else {
        if (closeButton && dirtyState) {
            [self setImage:self.dirtyInactive];
        } else {
            [self setImage:self.inactive];
        }
    }
}

- (void)hoverIn:(NSNotification *) notification {
    
    if ([[notification object] isEqual:[self superview]]) {
        hoverState = YES;
        if (closeButton && dirtyState) {
            [self setImage:self.dirtyHover];
        } else {
            [self setImage:self.hover];
        }
    }
}

- (void)hoverOut {
    hoverState = NO;
    if (activeState) {
        if (closeButton && dirtyState) {
            [self setImage:self.dirtyActive];
        } else {
            [self setImage:self.active];
        }
    } else {
        if (closeButton && dirtyState) {
            [self setImage:self.dirtyInactive];
        } else {
            [self setImage:self.inactive];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
