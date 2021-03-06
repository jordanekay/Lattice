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
#import "LatticeAppDelegate.h"

static NSString *const kDefaultHandlerKey     = @"defaultHandler";
static NSString *const kHashbangPathComponent = @"/#!";

@interface NSURL (Normalization)

- (NSURL *)normalizedURL;
- (NSURL *)urlWithScheme:(NSString *)scheme;

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
    [[url normalizedURL] expandFromHosts:[LatticeSchemes shortenedHostnames] expansion:^(NSURL *expandedURL) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSURL *mappedURL = [self _urlMappedFromURL:expandedURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(![self _openURLNatively:mappedURL]) {
                    [self _openURLInDefaultBrowser:mappedURL];
                }
            });
        });
    }];
}

- (NSURL *)_urlMappedFromURL:(NSURL *)url
{
    NSString *template;
    NSURL *mappedURL = url;
    NSString *host = [url.host stringByReplacingOccurrencesOfString:WWW withString:@""];
    NSString *scheme = [self _schemeMappedFromHost:host];
    if(scheme) {
        template = [self _templateForHost:host path:url.path];
    } else {
        scheme = [self _schemeMappedFromHost:host query:url.absoluteString template:&template];
    }
    if(scheme && template && [self _urlMatchesPath:url]) {
        if([template length]) {
            NSDictionary *parameters = [self _parametersForURL:url mappedToScheme:scheme fromTemplate:template];
            mappedURL = [self _urlWithParameters:parameters mappedToScheme:scheme fromTemplate:template];
        } else {
            mappedURL = [url urlWithScheme:scheme];
        }
    }
    return mappedURL;
}

- (BOOL)_openURLNatively:(NSURL *)url
{
    BOOL shouldOpen = NO;
    NSString *host = [url.host stringByReplacingOccurrencesOfString:WWW withString:@""];
    NSString *parameterTemplate = [LatticeSchemes nativeHosts][host];
    if(parameterTemplate) {
        shouldOpen = YES;
        NSString *string = url.absoluteString;
        NSRegularExpression *templateRegex = [NSRegularExpression regularExpressionWithPattern:parameterTemplate options:0 error:nil];
        NSTextCheckingResult *result = [[templateRegex matchesInString:string options:0 range:NSMakeRange(0, [string length])] lastObject];
        NSString *parameter = [string substringWithRange:[result rangeAtIndex:1]];
        [((LatticeAppDelegate *)[NSApp delegate]) openServiceFromHost:host withParameter:parameter];
    }
    return shouldOpen;
}

- (void)_openURLInDefaultBrowser:(NSURL *)url
{
    [self unregisterFromHandlingURLSchemes];
    [[NSWorkspace sharedWorkspace] openURL:url];
    [self registerToHandleURLSchemes];
}

- (BOOL)_urlMatchesPath:(NSURL *)url
{
    NSArray *hostnames = [LatticeSchemes hostnamesWithParameterlessPaths];
    NSString *pathWithParameters = [[url.absoluteString componentsSeparatedByString:url.host] lastObject];
    return !([hostnames containsObject:url.host] && ![pathWithParameters isEqualToString:url.path]);
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

- (NSString *)_schemeMappedFromHost:(NSString *)host query:(NSString *)query template:(NSString **)outTemplate
{
    NSArray *schemes = [LatticeSchemes queryBasedSchemesForHosts][host];
    for(NSString *scheme in schemes) {
        NSDictionary *templates = [LatticeSchemes templatesForSchemes][scheme];
        for(NSString *template in [templates allKeys]) {
            NSRegularExpression *templateRegex = [NSRegularExpression regularExpressionWithPattern:template options:0 error:nil];
            if([templateRegex firstMatchInString:query options:0 range:NSMakeRange(0, [query length])]) {
                *outTemplate = templates[template];
                return scheme;
            }
        }
    }
    return nil;
}

- (NSDictionary *)_parametersForURL:(NSURL *)url mappedToScheme:(NSString *)scheme fromTemplate:(NSString *)template
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSArray *oEmbedParameters = [LatticeSchemes oEmbedBasedParametersForHosts][url.host];
    NSDictionary *parametersForScheme = [LatticeSchemes parametersForSchemes][scheme][template];
    void (^parameterBlock)(NSString *parameter, NSUInteger index);
    if([[LatticeSchemes schemesWithCaptureGroups] containsObject:scheme]) {
        parameterBlock = ^(NSString *parameter, NSUInteger index) {
            NSRegularExpression *templateRegex = [NSRegularExpression regularExpressionWithPattern:template options:0 error:nil];
            NSArray *results = [templateRegex matchesInString:url.path options:0 range:NSMakeRange(0, [url.path length])];
            for(NSTextCheckingResult *result in results) {
                parameters[parameter] = [url.path substringWithRange:[result rangeAtIndex:index]];
            }
        };
    } else if(oEmbedParameters) {
        parameters = [NSMutableDictionary dictionaryWithDictionary:[self _parametersForURL:url oEmbedParameters:oEmbedParameters]];
    } else {
        parameterBlock = ^(NSString *parameter, NSUInteger index) {
            parameters[parameter] = url.pathComponents[index];
        };
    }
    if(parameterBlock) {
        for(NSString *parameter in parametersForScheme) {
            NSUInteger index = [parametersForScheme[parameter] unsignedIntValue];
            parameterBlock(parameter, index);
        }
    }
    return parameters;
}

- (NSDictionary *)_parametersForURL:(NSURL *)url oEmbedParameters:(NSArray *)oEmbedParameters
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *oEmbed = [LatticeSchemes oEmbedsForHosts][url.host];
    NSURL *oEmbedURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@%@%@", url.scheme, oEmbed, url.host, url.path]];
    NSData *oEmbedData = [NSData dataWithContentsOfURL:oEmbedURL];
    NSDictionary *oEmbedContents = [NSJSONSerialization JSONObjectWithData:oEmbedData options:0 error:nil];
    for(NSString *parameter in oEmbedParameters) {
        NSString *oEmbedParameter = oEmbedContents[parameter];
        if(oEmbedParameter) {
            parameters[parameter] = oEmbedParameter;
        }
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
    NSString *urlString = [self.absoluteString stringByReplacingOccurrencesOfString:kHashbangPathComponent withString:@""];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSString *hostPathParameterString = [url.absoluteString substringFromIndex:[url.scheme length]];
    NSString *scheme = [LatticeSchemes httpSchemesForScheme][url.scheme] ?: url.scheme;
    NSURL *normalizedURL = [[NSURL alloc] initWithString:[scheme stringByAppendingString:hostPathParameterString]];
    return normalizedURL;
}

- (NSURL *)urlWithScheme:(NSString *)scheme
{
    NSString *urlString = [[self.absoluteString componentsSeparatedByString:[self.scheme stringByAppendingString:@"://"]] lastObject];
    return [NSURL URLWithString:[scheme stringByAppendingString:urlString]];
}

@end