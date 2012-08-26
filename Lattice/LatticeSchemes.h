//
//  LatticeSchemes.h
//  Lattice
//
//  Created by Jordan Kay on 8/24/12.
//  Copyright (c) 2012 Jordan Kay
//

#import <Foundation/Foundation.h>

extern NSString *const kTcoHostname;

@interface LatticeSchemes : NSObject

+ (NSDictionary *)templatesForHosts;
+ (NSDictionary *)schemesForHosts;
+ (NSDictionary *)templatesForSchemes;
+ (NSDictionary *)parametersForSchemes;

@end
