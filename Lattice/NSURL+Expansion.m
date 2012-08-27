//
//  NSURL+Expansion.m
//  Lattice
//
//  Created by Jordan Kay on 8/25/12.
//  Copyright (c) 2012 Jordan Kay
//

#import "NSURL+Expansion.h"

@interface NSURLExpander : NSObject <NSURLConnectionDelegate>

- (id)initWithSourceHosts:(NSArray *)sourceHosts expansionBlock:(NSURLExpansionBlock)block;
- (void)expandURL:(NSURL *)url;

@end

@implementation NSURL (Expansion)

- (void)expandFromHosts:(NSArray *)hosts expansion:(NSURLExpansionBlock)expansionBlock
{
    static NSURLExpander *expander = nil;
    if(!expander) {
        expander = [[NSURLExpander alloc] initWithSourceHosts:hosts expansionBlock:expansionBlock];
    }
    [expander expandURL:self];
}

@end

@implementation NSURLExpander
{
    NSArray *_sourceHosts;
    NSURLConnection *_connection;
    NSURLExpansionBlock _expansionBlock;
}

- (id)initWithSourceHosts:(NSArray *)sourceHosts expansionBlock:(NSURLExpansionBlock)block
{
    if(self = [super init]) {
        _sourceHosts = sourceHosts;
        _expansionBlock = [block copy];
    }
    return self;
}

- (void)expandURL:(NSURL *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    if(![_sourceHosts containsObject:request.URL.host]) {
        if(_expansionBlock) {
            _expansionBlock(request.URL);
        }
        [_connection cancel];
        _connection = nil;
    }
    return request;
}

@end
