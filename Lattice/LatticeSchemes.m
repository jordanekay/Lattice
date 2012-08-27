//
//  LatticeSchemes.m
//  Lattice
//
//  Created by Jordan Kay on 8/24/12.
//  Copyright (c) 2012 Jordan Kay
//

#import "LatticeSchemes.h"

static NSString *const kLatticeScheme        = @"lattice";
static NSString *const kLatticeSchemeSecure  = @"lattices";

static NSString *const kTwitterHostname = @"twitter.com";
static NSString *const kTweetbotScheme  = @"tweetbot://";

static NSString *const kUsernameParameter = @"username";
static NSString *const kStatusIDParameter = @"statusID";

static NSString *const kUsernamePattern = @"[A-Za-z0-9_]{1,15}";
static NSString *const kStatusIDPattern = @"[0-9]+";

static NSString *const kITunesStoreHostname = @"itunes.apple.com";
static NSString *const kITunesStoreScheme   = @"itms://";
static NSString *const kMacAppStoreScheme   = @"macappstore://";

NSString *const kTcoHostname = @"t.co";

#define TWITTER_PROFILE_PATH_TEMPLATE [NSString stringWithFormat:@"^(/#!)?/%@$", kUsernamePattern]
#define TWITTER_STATUS_PATH_TEMPLATE  [NSString stringWithFormat:@"/status(es)?/%@$", kStatusIDPattern]

#define TWEETBOT_PROFILE_URL_TEMPLATE [NSString stringWithFormat:@"%@%@/user_profile/%@", kTweetbotScheme, kUsernameParameter, kUsernameParameter]
#define TWEETBOT_STATUS_URL_TEMPLATE  [NSString stringWithFormat:@"%@%@/status/%@", kTweetbotScheme, kUsernameParameter, kStatusIDParameter]

#define ITUNES_STORE_PATH_TEMPLATE  @"(8$|artist|album|playlist)"
#define MAC_APP_STORE_PATH_TEMPLATE @"12$"

@implementation LatticeSchemes

+ (NSDictionary *)httpSchemesForScheme
{
    return @{kLatticeScheme:       (__bridge NSString *)HTTP,
             kLatticeSchemeSecure: (__bridge NSString *)HTTPS};
}

+ (NSDictionary *)templatesForHosts
{
    return @{kTwitterHostname:     @[TWITTER_PROFILE_PATH_TEMPLATE, TWITTER_STATUS_PATH_TEMPLATE],
             kITunesStoreHostname: @[ITUNES_STORE_PATH_TEMPLATE, MAC_APP_STORE_PATH_TEMPLATE]};
}

+ (NSDictionary *)schemesForHosts
{
    return @{kTwitterHostname: kTweetbotScheme};
}

+ (NSDictionary *)queryBasedSchemesForHosts
{
    return @{kITunesStoreHostname: @[kITunesStoreScheme, kMacAppStoreScheme]};
}

+ (NSDictionary *)templatesForSchemes
{
    return @{kTweetbotScheme:    @{TWITTER_PROFILE_PATH_TEMPLATE: TWEETBOT_PROFILE_URL_TEMPLATE,
                                   TWITTER_STATUS_PATH_TEMPLATE:  TWEETBOT_STATUS_URL_TEMPLATE},
             kITunesStoreScheme: @{ITUNES_STORE_PATH_TEMPLATE : @""},
             kMacAppStoreScheme: @{MAC_APP_STORE_PATH_TEMPLATE : @""}};
}

+ (NSDictionary *)parametersForSchemes
{
    return @{kTweetbotScheme: @{TWITTER_PROFILE_PATH_TEMPLATE: @{kUsernameParameter: @1},
                                TWITTER_STATUS_PATH_TEMPLATE:  @{kUsernameParameter: @1, kStatusIDParameter: @3}}};
}

@end
