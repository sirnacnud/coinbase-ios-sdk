//
//  CBTokens.h
//  Pods
//
//  Created by Duncan Cunningham on 12/12/14.
//
//

#import <Foundation/Foundation.h>

@interface CBTokens : NSObject

+ (NSString*)accessToken;
+ (NSString*)authCode;
+ (NSNumber*)expiryTime;
+ (NSString*)refreshToken;

+ (void)setAccessToken:(NSString*)accessToken;
+ (void)setAuthCode:(NSString*)authCode;
+ (void)setExpiryTime:(NSNumber*)expiryTime;
+ (void)setRefreshToken:(NSString*)refreshToken;

+ (void)setService:(NSString*)service;
+ (void)setAccessGroup:(NSString*)accessGroup;

+ (void)resetTokens;

@end
