//
//  LatticeSchemes.m
//  Lattice
//
//  Created by Jordan Kay on 8/24/12.
//  Copyright (c) 2012 Jordan Kay
//

#import "LatticeSchemes.h"

static NSString *const kTwitterHostname = @"twitter.com";
static NSString *const kTweetbotScheme  = @"tweetbot://";

static NSString *const kUsernameParameter = @"username";
static NSString *const kStatusIDParameter = @"statusID";

#define TWEETBOT_STATUS_URL_TEMPLATE [NSString stringWithFormat:@"%@%@/status/%@", kTweetbotScheme, kUsernameParameter, kStatusIDParameter]

@implementation LatticeSchemes

+ (NSDictionary *)schemesForHosts
{
    return @{kTwitterHostname: kTweetbotScheme};
}

+ (NSDictionary *)templatesForSchemes
{
    return @{kTweetbotScheme: TWEETBOT_STATUS_URL_TEMPLATE};
}

+ (NSDictionary *)parametersForSchemes
{
    return @{kTweetbotScheme: @{kUsernameParameter: @1, kStatusIDParameter: @3}};
}

@end
