//
//  LatticeURLHandler.h
//  Lattice
//
//  Created by Jordan Kay on 8/21/12.
//  Copyright (c) 2012 Jordan Kay
//

#import <Foundation/Foundation.h>

@interface LatticeURLHandler : NSObject

+ (LatticeURLHandler *)sharedHandler;
- (void)registerToHandleURLSchemes;
- (void)unregisterFromHandlingURLSchemes;
- (void)registerForURLEvents;
- (void)unregisterForURLEvents;

@end
