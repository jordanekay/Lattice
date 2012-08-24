//
//  LatticeURLHandler.m
//  Lattice
//
//  Created by Jordan Kay on 8/21/12.
//  Copyright (c) 2012 Jordan Kay
//

#import "LatticeURLHandler.h"

#define HTTP  CFSTR("http")
#define HTTPS CFSTR("https")

static NSString *const kDefaultHandlerKey = @"defaultHandler";

static NSString *const kTwitterHostname = @"twitter.com";
static NSString *const kTweetbotScheme  = @"tweetbot://";

static NSString *const kUsernameParameter = @"username";
static NSString *const kStatusIDParameter = @"statusID";

#define TWEETBOT_STATUS_URL_TEMPLATE [NSString stringWithFormat:@"%@%@/status/%@", kTweetbotScheme, kUsernameParameter, kStatusIDParameter]

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

+ (NSDictionary *)schemesForHosts
{
    return @{kTwitterHostname: kTweetbotScheme};
}

+ (NSDictionary *)templatesForSchemes
{
    return @{kTweetbotScheme: TWEETBOT_STATUS_URL_TEMPLATE};
}

+ (NSDictionary *)parametersForSchemes
{
    return @{kTweetbotScheme: @{kUsernameParameter: @1, kStatusIDParameter: @3}};
}

- (NSString *)_schemeMappedFromHost:(NSString *)host
{
    return [[self class] schemesForHosts][host];
}

- (NSDictionary *)_parametersForURL:(NSURL *)url mappedToScheme:(NSString *)scheme
{
    NSDictionary *parametersForScheme = [[self class] parametersForSchemes][scheme];
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
    NSString *urlTemplate = [[self class] templatesForSchemes][scheme];
    for(NSString *parameterName in parameters) {
        url = [urlTemplate stringByReplacingOccurrencesOfString:parameterName withString:parameters[parameterName] options:NSLiteralSearch range:NSMakeRange(0, [urlTemplate length])];
    }
    return [NSURL URLWithString:url];
}

- (void)registerToHandleURLSchemes
{
    CFStringRef bundleID = (__bridge CFStringRef)[[NSBundle mainBundle] bundleIdentifier];
    CFStringRef savedDefaultHandler = (__bridge CFStringRef)[[NSUserDefaults standardUserDefaults] stringForKey:kDefaultHandlerKey];
    if(!savedDefaultHandler) {
        _defaultHandler = LSCopyDefaultHandlerForURLScheme(HTTP);
    } else {
        _defaultHandler = savedDefaultHandler;
    }
    if([(__bridge NSString *)_defaultHandler isEqualToString:(__bridge NSString *)bundleID]) {
        _defaultHandler = savedDefaultHandler;
    }
    [[NSUserDefaults standardUserDefaults] setObject:(__bridge NSString *)_defaultHandler forKey:kDefaultHandlerKey];
    LSSetDefaultHandlerForURLScheme(HTTP, bundleID);
    LSSetDefaultHandlerForURLScheme(HTTPS, bundleID);
}

- (void)unregisterFromHandlingURLSchemes
{
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

- (void)openURLInDefaultBrowser:(NSURL *)url
{
    [self unregisterFromHandlingURLSchemes];
    [[NSWorkspace sharedWorkspace] openURL:url];
    [self registerToHandleURLSchemes];
}

- (void)_handleURLEvent:(NSAppleEventDescriptor *)event
{
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    NSString *scheme = [self _schemeMappedFromHost:[url host]];
    if(scheme) {
        NSDictionary *parameters = [self _parametersForURL:url mappedToScheme:scheme];
        url = [self _urlWithParameters:parameters mappedToScheme:scheme];
    }
    [self openURLInDefaultBrowser:url];
}

@end