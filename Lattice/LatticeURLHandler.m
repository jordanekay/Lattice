//
//  LatticeURLHandler.m
//  Lattice
//
//  Created by Jordan Kay on 8/21/12.
//  Copyright (c) 2012 Jordan Kay
//

#import "LatticeSchemes.h"
#import "LatticeURLHandler.h"
#import "NSURL+Expansion.h"

#define HTTP  CFSTR("http")
#define HTTPS CFSTR("https")

static NSString *const kDefaultHandlerKey     = @"defaultHandler";
static NSString *const kHashbangPathComponent = @"/#!";

@interface NSURL (Normalization)

- (NSURL *)normalizedURL;

@end

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
    if(CFStringCompare(_defaultHandler, bundleID, 0) == kCFCompareEqualTo) {
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
    [[url normalizedURL] expandFromHost:kTcoHostname expansion:[self _openURLBlock]];
}

- (NSURLExpansionBlock)_openURLBlock
{
    return [^(NSURL *expandedURL) {
        NSURL *url = expandedURL;
        NSString *scheme = [self _schemeMappedFromHost:url.host];
        NSString *template = [self _templateForHost:url.host path:url.path];
        if(scheme && template) {
            NSDictionary *parameters = [self _parametersForURL:url mappedToScheme:scheme fromTemplate:template];
            url = [self _urlWithParameters:parameters mappedToScheme:scheme fromTemplate:template];
        }
        [self _openURLInDefaultBrowser:url];
    } copy];
}

- (void)_openURLInDefaultBrowser:(NSURL *)url
{
    [self unregisterFromHandlingURLSchemes];
    [[NSWorkspace sharedWorkspace] openURL:url];
    [self registerToHandleURLSchemes];
}

- (NSString *)_templateForHost:(NSString *)host path:(NSString *)path
{
    NSArray *templates = [LatticeSchemes templatesForHosts][host];
    NSString *matchedTemplate;
    for(NSString *template in templates) {
        NSRegularExpression *templateRegex = [NSRegularExpression regularExpressionWithPattern:template options:0 error:nil];
        if([templateRegex firstMatchInString:path options:0 range:NSMakeRange(0, [path length])]) {
            matchedTemplate = template;
        }
    }
    return matchedTemplate;
}

- (NSString *)_schemeMappedFromHost:(NSString *)host
{
    return [LatticeSchemes schemesForHosts][host];
}

- (NSDictionary *)_parametersForURL:(NSURL *)url mappedToScheme:(NSString *)scheme fromTemplate:(NSString *)template
{
    NSDictionary *parametersForScheme = [LatticeSchemes parametersForSchemes][scheme][template];
    NSArray *components = [url.path componentsSeparatedByString:@"/"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    for(NSString *parameter in parametersForScheme) {
        NSUInteger index = [parametersForScheme[parameter] unsignedIntValue];
        parameters[parameter] = components[index];
    }
    return parameters;
}
                            
- (NSURL *)_urlWithParameters:(NSDictionary *)parameters mappedToScheme:(NSString *)scheme fromTemplate:(NSString *)template
{
    NSString *url;
    NSString *urlTemplate = [LatticeSchemes templatesForSchemes][scheme][template];
    for(NSString *parameterName in parameters) {
        url = [urlTemplate stringByReplacingOccurrencesOfString:parameterName withString:parameters[parameterName]];
    }
    return [NSURL URLWithString:url];
}

@end

@implementation NSURL (Normalization)

- (NSURL *)normalizedURL
{
    NSURL *url = [[NSURL alloc] initWithString:[self.absoluteString stringByReplacingOccurrencesOfString:kHashbangPathComponent withString:@""]];
    NSString *hostPathParameterString = [[url.absoluteString componentsSeparatedByString:url.scheme] lastObject];
    NSURL *normalizedURL = [[NSURL alloc] initWithString:[(__bridge NSString *)HTTP stringByAppendingString:hostPathParameterString]];
    return normalizedURL;
}

@end