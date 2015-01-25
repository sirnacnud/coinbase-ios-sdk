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
    return [UICKeyChainStore stringForKey:CBTokensAccessTokenKey service:CBTokensService];
}

+ (NSString*)authCode
{
    return [UICKeyChainStore stringForKey:CBTokensAuthCodeKey service:CBTokensService];
}

+ (NSNumber*)expiryTime
{
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:[UICKeyChainStore stringForKey:CBTokensExpiryTimeKey service:CBTokensService]];
}

+ (NSString*)refreshToken
{
    return [UICKeyChainStore stringForKey:CBTokensRefreshTokenKey service:CBTokensService];
}

+ (void)setAccessToken:(NSString*)accessToken
{
    [UICKeyChainStore setString:accessToken forKey:CBTokensAccessTokenKey service:CBTokensService];
}

+ (void)setAuthCode:(NSString*)authCode
{
    [UICKeyChainStore setString:authCode forKey:CBTokensAuthCodeKey service:CBTokensService];
}

+ (void)setExpiryTime:(NSNumber*)expiryTime
{
    [UICKeyChainStore setString:[expiryTime stringValue] forKey:CBTokensExpiryTimeKey service:CBTokensService];
}

+ (void)setRefreshToken:(NSString*)refreshToken
{
    [UICKeyChainStore setString:refreshToken forKey:CBTokensRefreshTokenKey service:CBTokensService];
}

+ (void)setService:(NSString *)service
{
    CBTokensService = service;
}

+ (void)resetTokens
{
    [UICKeyChainStore removeItemForKey:CBTokensAccessTokenKey service:CBTokensService];
    [UICKeyChainStore removeItemForKey:CBTokensAuthCodeKey service:CBTokensService];
    [UICKeyChainStore removeItemForKey:CBTokensExpiryTimeKey service:CBTokensService];
    [UICKeyChainStore removeItemForKey:CBTokensRefreshTokenKey service:CBTokensService];
}

@end
