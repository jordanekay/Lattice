//
//  LatticeAppDelegate.m
//  Lattice
//
//  Created by Jordan Kay on 8/21/12.
//  Copyright (c) 2012 Jordan Kay
//

#import <WebKit/WebKit.h>
#import "LatticeAppDelegate.h"
#import "LatticeURLHandler.h"
#import "LatticeSchemes.h"

@implementation LatticeAppDelegate
{
    NSMutableArray *_windows;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _windows = [NSMutableArray array];
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

- (void)openServiceFromHost:(NSString *)host withParameter:(NSString *)parameter
{
    NSRect frame = NSMakeRect(700, 500, 640, 385);
    NSString *title = @"Video";
    NSWindow *window = [[NSWindow alloc] initWithContentRect:frame styleMask:NSTitledWindowMask | NSClosableWindowMask backing:NSBackingStoreBuffered defer:NO];
    WebView *webView = [[WebView alloc] initWithFrame:frame frameName:nil groupName:nil];
    NSString *embedString = [NSString stringWithFormat:[LatticeSchemes embedStrings][host], parameter];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:embedString]];
    [[webView mainFrame] loadRequest:request];
    
    window.title = title;
    window.contentView = webView;
    [window makeKeyAndOrderFront:nil];
    [_windows addObject:window];
}

@end
