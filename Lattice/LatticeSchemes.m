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

static NSString *const kADNHostname          = @"alpha.app.net";
static NSString *const kADNShortPostHostname = @"posts.app.net";
static NSString *const kNetbotScheme         = @"netbot://";

static NSString *const kITunesStoreHostname = @"itunes.apple.com";
static NSString *const kITunesStoreScheme   = @"itms://";
static NSString *const kMacAppStoreScheme   = @"macappstore://";

static NSString *const kAppleDeveloperHostname = @"developer.apple.com";
static NSString *const kDashScheme             = @"dash://";

static NSString *const kSpotifyHostname = @"open.spotify.com";
static NSString *const kSpotifyScheme   = @"spotify://";

static NSString *const kRdioHostname = @"rdio.com";
static NSString *const kRdioScheme   = @"rdio://";

static NSString *const kYoutubeHostname = @"youtube.com";

static NSString *const kInstagramHostname = @"instagram.com";
static NSString *const kInstagramOEmbed   = @"api.instagram.com/oembed?url=";
static NSString *const kCarouselScheme    = @"x-mobelux-carousel://";

static NSString *const kUsernameParameter   = @"username";
static NSString *const kStatusIDParameter   = @"statusID";
static NSString *const kPostIDParameter     = @"statusID";
static NSString *const kClassNameParameter  = @"className";
static NSString *const kResourceIDParameter = @"resourceID";
static NSString *const kMediaIDParameter    = @"media_id";

static NSString *const kUsernamePattern = @"[A-Za-z0-9_]{1,15}";
static NSString *const kStatusIDPattern = @"[0-9]+";
static NSString *const kPostIDPattern   = @"[0-9]+";

static NSString *const kTcoHostname          = @"t.co";
static NSString *const kSpotifiHostname      = @"spoti.fi";
static NSString *const kITunesShortHostname  = @"itun.es";
static NSString *const kRdioShortHostname    = @"rd.io";
static NSString *const kYoutubeShortHostname = @"youtu.be";
static NSString *const kBitlyHostname        = @"bit.ly";
static NSString *const kJmpHostname          = @"j.mp";
static NSString *const kInstagrHostName      = @"instagr.am";

#define TWITTER_PROFILE_PATH_TEMPLATE [NSString stringWithFormat:@"^(/#!)?/%@$", kUsernamePattern]
#define TWITTER_STATUS_PATH_TEMPLATE  [NSString stringWithFormat:@"/status(es)?/%@$", kStatusIDPattern]

#define ADN_PROFILE_PATH_TEMPLATE     [NSString stringWithFormat:@"^/%@$", kUsernamePattern]
#define ADN_SHORT_POST_PATH_TEMPLATE  [NSString stringWithFormat:@"/%@$", kPostIDPattern]
#define ADN_POST_PATH_TEMPLATE        [NSString stringWithFormat:@"/post/%@$", kPostIDPattern]

#define TWEETBOT_PROFILE_URL_TEMPLATE [NSString stringWithFormat:@"%@%@/user_profile/%@", kTweetbotScheme, kUsernameParameter, kUsernameParameter]
#define TWEETBOT_STATUS_URL_TEMPLATE  [NSString stringWithFormat:@"%@%@/status/%@", kTweetbotScheme, kUsernameParameter, kStatusIDParameter]

#define NETBOT_PROFILE_URL_TEMPLATE [NSString stringWithFormat:@"%@%@/user_profile/%@", kNetbotScheme, kUsernameParameter, kUsernameParameter]
#define NETBOT_POST_URL_TEMPLATE    [NSString stringWithFormat:@"%@%@/status/%@", kNetbotScheme, kUsernameParameter, kPostIDParameter]

#define ITUNES_STORE_PATH_TEMPLATE  @"(8$|artist|album|playlist)"
#define MAC_APP_STORE_PATH_TEMPLATE @"12$"

#define APPLE_DOCUMENTATION_PATH_TEMPLATE @"/.*/(.*)_(C|c)lass"
#define DASH_DOCUMENTATION_URL_TEMPLATE [NSString stringWithFormat:@"%@%@", kDashScheme, kClassNameParameter]

#define SPOTIFY_PATH_TEMPLATE @"^/(.*)"
#define SPOTIFY_URL_TEMPLATE  [NSString stringWithFormat:@"%@%@", kSpotifyScheme, kResourceIDParameter]

#define RDIO_PATH_TEMPLATE @"^/(.*)"
#define RDIO_URL_TEMPLATE  [NSString stringWithFormat:@"%@%@/%@", kRdioScheme, kRdioHostname, kResourceIDParameter]

#define YOUTUBE_PARAMETER_TEMPLATE @"watch\\?v=([^&]*)"
#define YOUTUBE_EMBED_TEMPLATE [NSString stringWithFormat:@"%@://%@%@/embed/%@?html5=True&autoplay=1", HTTP, WWW, kYoutubeHostname, @"%@"]

#define INSTAGRAM_PATH_TEMPLATE @"^/p/.+$"
#define CAROUSEL_URL_TEMPLATE [NSString stringWithFormat:@"%@openmedia?mediaID=%@", kCarouselScheme, kMediaIDParameter]

@implementation LatticeSchemes

+ (NSDictionary *)httpSchemesForScheme
{
    return @{kLatticeScheme: (__bridge NSString *)HTTP,
       kLatticeSchemeSecure: (__bridge NSString *)HTTPS};
}

+ (NSDictionary *)templatesForHosts
{
    return @{kTwitterHostname: @[TWITTER_PROFILE_PATH_TEMPLATE, TWITTER_STATUS_PATH_TEMPLATE],
                 kADNHostname: @[ADN_PROFILE_PATH_TEMPLATE, ADN_POST_PATH_TEMPLATE],
        kADNShortPostHostname: @[ADN_SHORT_POST_PATH_TEMPLATE],
         kITunesStoreHostname: @[ITUNES_STORE_PATH_TEMPLATE, MAC_APP_STORE_PATH_TEMPLATE],
      kAppleDeveloperHostname: @[APPLE_DOCUMENTATION_PATH_TEMPLATE],
             kSpotifyHostname: @[SPOTIFY_PATH_TEMPLATE],
                kRdioHostname: @[RDIO_PATH_TEMPLATE],
           kInstagramHostname: @[INSTAGRAM_PATH_TEMPLATE]};
}

+ (NSDictionary *)schemesForHosts
{
    return @{kTwitterHostname: kTweetbotScheme,
                 kADNHostname: kNetbotScheme,
        kADNShortPostHostname: kNetbotScheme,
      kAppleDeveloperHostname: kDashScheme,
             kSpotifyHostname: kSpotifyScheme,
                kRdioHostname: kRdioScheme,
           kInstagramHostname: kCarouselScheme};
}

+ (NSDictionary *)queryBasedSchemesForHosts
{
    return @{kITunesStoreHostname: @[kITunesStoreScheme, kMacAppStoreScheme]};
}

+ (NSDictionary *)oEmbedsForHosts
{
    return @{kInstagramHostname: kInstagramOEmbed};
}

+ (NSDictionary *)oEmbedBasedParametersForHosts
{
    return @{kInstagramHostname: @[kMediaIDParameter]};
}

+ (NSDictionary *)templatesForSchemes
{
    return @{kTweetbotScheme:     @{TWITTER_PROFILE_PATH_TEMPLATE: TWEETBOT_PROFILE_URL_TEMPLATE,
                                     TWITTER_STATUS_PATH_TEMPLATE: TWEETBOT_STATUS_URL_TEMPLATE},
               kNetbotScheme:         @{ADN_PROFILE_PATH_TEMPLATE: NETBOT_PROFILE_URL_TEMPLATE,
                                           ADN_POST_PATH_TEMPLATE: NETBOT_POST_URL_TEMPLATE,
                                     ADN_SHORT_POST_PATH_TEMPLATE: NETBOT_POST_URL_TEMPLATE},
          kITunesStoreScheme:        @{ITUNES_STORE_PATH_TEMPLATE: @""},
          kMacAppStoreScheme:       @{MAC_APP_STORE_PATH_TEMPLATE: @""},
                 kDashScheme: @{APPLE_DOCUMENTATION_PATH_TEMPLATE: DASH_DOCUMENTATION_URL_TEMPLATE},
              kSpotifyScheme:             @{SPOTIFY_PATH_TEMPLATE: SPOTIFY_URL_TEMPLATE},
                 kRdioScheme:                @{RDIO_PATH_TEMPLATE: RDIO_URL_TEMPLATE},
             kCarouselScheme:           @{INSTAGRAM_PATH_TEMPLATE: CAROUSEL_URL_TEMPLATE}};
}

+ (NSDictionary *)parametersForSchemes
{
    return @{kTweetbotScheme:     @{TWITTER_PROFILE_PATH_TEMPLATE: @{kUsernameParameter: @1},
                                     TWITTER_STATUS_PATH_TEMPLATE: @{kUsernameParameter: @1, kStatusIDParameter: @3}},
               kNetbotScheme:         @{ADN_PROFILE_PATH_TEMPLATE: @{kUsernameParameter: @1},
                                           ADN_POST_PATH_TEMPLATE: @{kUsernameParameter: @1, kPostIDParameter: @3},
                                     ADN_SHORT_POST_PATH_TEMPLATE: @{kPostIDParameter: @1}},
                 kDashScheme: @{APPLE_DOCUMENTATION_PATH_TEMPLATE: @{kClassNameParameter: @1}},
              kSpotifyScheme:             @{SPOTIFY_PATH_TEMPLATE: @{kResourceIDParameter: @1}},
                 kRdioScheme:                @{RDIO_PATH_TEMPLATE: @{kResourceIDParameter: @1}}};
}

+ (NSDictionary *)nativeHosts
{
    return @{kYoutubeHostname: YOUTUBE_PARAMETER_TEMPLATE};
}

+ (NSDictionary *)embedStrings
{
    return @{kYoutubeHostname: YOUTUBE_EMBED_TEMPLATE};
}

+ (NSArray *)schemesWithCaptureGroups
{
    return @[kDashScheme, kSpotifyScheme, kRdioScheme];
}

+ (NSArray *)hostnamesWithParameterlessPaths
{
    return @[kTwitterHostname];
}

+ (NSArray *)shortenedHostnames
{
    return @[kTcoHostname, kSpotifiHostname, kITunesShortHostname, kRdioShortHostname, kYoutubeShortHostname, kBitlyHostname, kJmpHostname, kInstagrHostName];
}

@end
