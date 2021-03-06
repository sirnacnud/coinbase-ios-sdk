//
//  Coinbase.h
//  Handshake
//
//  Created by Josh Beal on 11/11/13.
//  Copyright (c) 2013 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "CBHandlers.h"

FOUNDATION_EXPORT NSString *const CB_AUTH_CODE_NOTIFICATION_TYPE;
FOUNDATION_EXPORT NSString *const CB_AUTH_CODE_URL_KEY;

@interface Coinbase : NSObject

+ (BOOL)isAuthenticated;

+ (NSString *)getClientId;
+ (NSString *)getClientSecret;
+ (NSString *)getCallbackUrl;

+ (void)setClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;

+ (void)login:(LoginHandler)handler;
+ (void)loginWithScope:(NSArray *)permissions withHandler:(LoginHandler)handler;
+ (void)logout;

+ (void)registerAuthCode:(NSString *)authCode;

+ (void)getAccount:(AccountHandler)handler __attribute__((deprecated("Use getUser instead")));
+ (void)getUser:(UserHandler)handler;
+ (void)getUserTwo:(UserTwoHandler)handler;

@end
