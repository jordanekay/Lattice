//
//  NSURL+Expansion.m
//  Lattice
//
//  Created by Jordan Kay on 8/25/12.
//  Copyright (c) 2012 Jordan Kay
//

#import "NSURL+Expansion.h"

@interface NSURLExpander : NSObject <NSURLConnectionDelegate>

- (id)initWithSourceHost:(NSString *)sourceHost expansionBlock:(NSURLExpansionBlock)block;
- (void)expandURL:(NSURL *)url;

@end

@implementation NSURL (Expansion)

- (void)expandFromHost:(NSString *)host expansion:(NSURLExpansionBlock)expansionBlock
{
    static NSURLExpander *expander = nil;
    if(!expander) {
        expander = [[NSURLExpander alloc] initWithSourceHost:host expansionBlock:expansionBlock];
    }
    [expander expandURL:self];
}

@end

@implementation NSURLExpander
{
    NSString *_sourceHost;
    NSURLConnection *_connection;
    NSURLExpansionBlock _expansionBlock;
}

- (id)initWithSourceHost:(NSString *)sourceHost expansionBlock:(NSURLExpansionBlock)block
{
    if(self = [super init]) {
        _sourceHost = [sourceHost copy];
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
    if(![request.URL.host isEqualToString:_sourceHost]) {
        if(_expansionBlock) {
            _expansionBlock(request.URL);
        }
        [_connection cancel];
        _connection = nil;
    }
    return request;
}

@end
