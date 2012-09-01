//
//  LatticeSchemes.h
//  Lattice
//
//  Created by Jordan Kay on 8/24/12.
//  Copyright (c) 2012 Jordan Kay
//

#import <Foundation/Foundation.h>

#define HTTP  CFSTR("http")
#define HTTPS CFSTR("https")
#define WWW @"www."

@interface LatticeSchemes : NSObject

+ (NSDictionary *)httpSchemesForScheme;
+ (NSDictionary *)templatesForHosts;
+ (NSDictionary *)schemesForHosts;
+ (NSDictionary *)oEmbedsForHosts;
+ (NSDictionary *)oEmbedBasedParametersForHosts;
+ (NSDictionary *)queryBasedSchemesForHosts;
+ (NSDictionary *)templatesForSchemes;
+ (NSDictionary *)parametersForSchemes;
+ (NSArray *)schemesWithCaptureGroups;
+ (NSArray *)hostnamesWithParameterlessPaths;
+ (NSArray *)shortenedHostnames;

@end
