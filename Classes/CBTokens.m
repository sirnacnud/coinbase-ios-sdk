//
//  CBTokens.m
//  Pods
//
//  Created by Duncan Cunningham on 12/12/14.
//
//

#import "CBTokens.h"

#import <UICKeyChainStore.h>

@implementation CBTokens

NSString* const CBTokensAccessTokenKey = @"CBTokensAccessTokenKey";
NSString* const CBTokensAuthCodeKey = @"CBTokensAuthCodeKey";
NSString* const CBTokensExpiryTimeKey = @"CBTokensExpiryTimeKey";
NSString* const CBTokensRefreshTokenKey = @"CBTokensRefreshTokenKey";
NSString* const CBTokensFirstRunKey = @"CBTokensFirstRunKey";

static NSString* CBTokensService = nil;
static NSString* CBTokensAccessGroup = nil;

+ (void)initialize
{
    if( self == [CBTokens class] )
    {
        if( ![[NSUserDefaults standardUserDefaults] objectForKey:CBTokensFirstRunKey] )
        {
            // Clear out tokens left from a previous install of the application
            [self resetTokens];
            
            [[NSUserDefaults standardUserDefaults] setValue:@"dummyValue" forKey:CBTokensFirstRunKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

+ (NSString*)accessToken
{
    return [UICKeyChainStore stringForKey:CBTokensAccessTokenKey service:CBTokensService accessGroup:CBTokensAccessGroup];
}

+ (NSString*)authCode
{
    return [UICKeyChainStore stringForKey:CBTokensAuthCodeKey service:CBTokensService accessGroup:CBTokensAccessGroup];
}

+ (NSNumber*)expiryTime
{
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:[UICKeyChainStore stringForKey:CBTokensExpiryTimeKey service:CBTokensService accessGroup:CBTokensAccessGroup]];
}

+ (NSString*)refreshToken
{
    return [UICKeyChainStore stringForKey:CBTokensRefreshTokenKey service:CBTokensService accessGroup:CBTokensAccessGroup];
}

+ (void)setAccessToken:(NSString*)accessToken
{
    [UICKeyChainStore setString:accessToken forKey:CBTokensAccessTokenKey service:CBTokensService accessGroup:CBTokensAccessGroup];
}

+ (void)setAuthCode:(NSString*)authCode
{
    [UICKeyChainStore setString:authCode forKey:CBTokensAuthCodeKey service:CBTokensService accessGroup:CBTokensAccessGroup];
}

+ (void)setExpiryTime:(NSNumber*)expiryTime
{
    [UICKeyChainStore setString:[expiryTime stringValue] forKey:CBTokensExpiryTimeKey service:CBTokensService accessGroup:CBTokensAccessGroup];
}

+ (void)setRefreshToken:(NSString*)refreshToken
{
    [UICKeyChainStore setString:refreshToken forKey:CBTokensRefreshTokenKey service:CBTokensService accessGroup:CBTokensAccessGroup];
}

+ (void)setService:(NSString *)service
{
    CBTokensService = service;
}

+ (void)setAccessGroup:(NSString*)accessGroup
{
    CBTokensAccessGroup = accessGroup;
}

+ (void)resetTokens
{
    [UICKeyChainStore removeItemForKey:CBTokensAccessTokenKey service:CBTokensService accessGroup:CBTokensAccessGroup];
    [UICKeyChainStore removeItemForKey:CBTokensAuthCodeKey service:CBTokensService accessGroup:CBTokensAccessGroup];
    [UICKeyChainStore removeItemForKey:CBTokensExpiryTimeKey service:CBTokensService accessGroup:CBTokensAccessGroup];
    [UICKeyChainStore removeItemForKey:CBTokensRefreshTokenKey service:CBTokensService accessGroup:CBTokensAccessGroup];
}

@end
