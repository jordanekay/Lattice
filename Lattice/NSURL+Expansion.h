//
//  NSURL+Expansion.h
//  Lattice
//
//  Created by Jordan Kay on 8/25/12.
//  Copyright (c) 2012 Jordan Kay
//

typedef void (^ NSURLExpansionBlock)(NSURL *expandedURL);

@interface NSURL (Expansion)

- (void)expandFromHost:(NSString *)host expansion:(NSURLExpansionBlock)expansionBlock;

@end
