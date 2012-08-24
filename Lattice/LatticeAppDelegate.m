//
//  LatticeAppDelegate.m
//  Lattice
//
//  Created by Jordan Kay on 8/21/12.
//  Copyright (c) 2012 Jordan Kay
//

#import "LatticeAppDelegate.h"
#import "LatticeURLHandler.h"

@implementation LatticeAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    LatticeURLHandler *handler = [LatticeURLHandler sharedHandler];
    [handler registerToHandleURLSchemes];
    [handler registerForURLEvents];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    LatticeURLHandler *handler = [LatticeURLHandler sharedHandler];
    [handler unregisterForURLEvents];
    [handler unregisterFromHandlingURLSchemes];
}

@end
