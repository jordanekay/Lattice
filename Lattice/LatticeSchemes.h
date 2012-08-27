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

extern NSString *const kTcoHostname;

@interface LatticeSchemes : NSObject

+ (NSDictionary *)httpSchemesForScheme;
+ (NSDictionary *)templatesForHosts;
+ (NSDictionary *)schemesForHosts;
+ (NSDictionary *)queryBasedSchemesForHosts;
+ (NSDictionary *)templatesForSchemes;
+ (NSDictionary *)parametersForSchemes;
+ (NSArray *)schemesWithCaptureGroups;
+ (NSArray *)shortenedHostnames;

@end
