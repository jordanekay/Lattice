//
//  LatticeURLHandler.m
//  Lattice
//
//  Created by Jordan Kay on 8/21/12.
//  Copyright (c) 2012 Jordan Kay
//

#import "LatticeSchemes.h"
#import "LatticeURLHandler.h"

#define HTTP  CFSTR("http")
#define HTTPS CFSTR("https")

static NSString *const kDefaultHandlerKey = @"defaultHandler";

@implementation LatticeURLHandler
{
    CFStringRef _defaultHandler;
}

+ (LatticeURLHandler *)sharedHandler
{
    static dispatch_once_t once;
    static LatticeURLHandler *sharedHandler;
    dispatch_once(&once, ^{ 
        sharedHandler = [[self alloc] init]; 
    });
    return sharedHandler;
}

- (void)registerToHandleURLSchemes
{
    // Grab the current handler (user’s default browser)
    CFStringRef bundleID = (__bridge CFStringRef)[[NSBundle mainBundle] bundleIdentifier];
    CFStringRef savedDefaultHandler = (__bridge CFStringRef)[[NSUserDefaults standardUserDefaults] stringForKey:kDefaultHandlerKey];
    if(!savedDefaultHandler) {
        _defaultHandler = LSCopyDefaultHandlerForURLScheme(HTTP);
    } else {
        _defaultHandler = savedDefaultHandler;
    }
    // We never want Lattice to be the default handler
    // If it is, revert to the last saved handler (guaranteed not to be Lattice)
    if([(__bridge NSString *)_defaultHandler isEqualToString:(__bridge NSString *)bundleID]) {
        _defaultHandler = savedDefaultHandler;
    }
    [[NSUserDefaults standardUserDefaults] setObject:(__bridge NSString *)_defaultHandler forKey:kDefaultHandlerKey];
    // Set Lattice as the “default browser”
    LSSetDefaultHandlerForURLScheme(HTTP, bundleID);
    LSSetDefaultHandlerForURLScheme(HTTPS, bundleID);
}

- (void)unregisterFromHandlingURLSchemes
{
    // Revert to original “default browser”
    LSSetDefaultHandlerForURLScheme(HTTP, _defaultHandler);
    LSSetDefaultHandlerForURLScheme(HTTPS, _defaultHandler);
}

- (void)registerForURLEvents
{
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(_handleURLEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)unregisterForURLEvents
{
    [[NSAppleEventManager sharedAppleEventManager] removeEventHandlerForEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)_handleURLEvent:(NSAppleEventDescriptor *)event
{
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    NSString *scheme = [self _schemeMappedFromHost:[url host]];
    if(scheme) {
        NSDictionary *parameters = [self _parametersForURL:url mappedToScheme:scheme];
        url = [self _urlWithParameters:parameters mappedToScheme:scheme];
    }
    [self _openURLInDefaultBrowser:url];
}

- (void)_openURLInDefaultBrowser:(NSURL *)url
{
    [self unregisterFromHandlingURLSchemes];
    [[NSWorkspace sharedWorkspace] openURL:url];
    [self registerToHandleURLSchemes];
}

- (NSString *)_schemeMappedFromHost:(NSString *)host
{
    return [LatticeSchemes schemesForHosts][host];
}

- (NSDictionary *)_parametersForURL:(NSURL *)url mappedToScheme:(NSString *)scheme
{
    NSDictionary *parametersForScheme = [LatticeSchemes parametersForSchemes][scheme];
    NSArray *components = [[url path] componentsSeparatedByString:@"/"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    for(NSString *parameter in parametersForScheme) {
        NSUInteger index = [parametersForScheme[parameter] unsignedIntValue];
        parameters[parameter] = components[index];
    }
    return parameters;
}
                            
- (NSURL *)_urlWithParameters:(NSDictionary *)parameters mappedToScheme:(NSString *)scheme
{
    NSString *url;
    NSString *urlTemplate = [LatticeSchemes templatesForSchemes][scheme];
    for(NSString *parameterName in parameters) {
        url = [urlTemplate stringByReplacingOccurrencesOfString:parameterName withString:parameters[parameterName]];
    }
    return [NSURL URLWithString:url];
}

@end
