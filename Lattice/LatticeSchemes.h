//
//  LatticeSchemes.h
//  Lattice
//
//  Created by Jordan Kay on 8/24/12.
//  Copyright (c) 2012 Twitter, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LatticeSchemes : NSObject

+ (NSDictionary *)schemesForHosts;
+ (NSDictionary *)templatesForSchemes;
+ (NSDictionary *)parametersForSchemes;

@end
