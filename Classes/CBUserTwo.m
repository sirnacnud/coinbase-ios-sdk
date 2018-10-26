//
//  CBUserTwo.m
//  Pods
//
//  Created by Duncan Cunningham on 10/16/18.
//  Copyright © 2018 Duncan Cunningham. All rights reserved.
//

#import "CBUserTwo.h"
#import "CBAccountTwo.h"
#import "CBRequest.h"
#import "CBTokens.h"
#import <AFNetworking/AFNetworking.h>

@implementation CBUserTwo

- (void)fetchAccounts:(NSMutableArray*)accounts withStartUri:(NSString*)startUri withHandler:(AccountsHandler)handler {
    [CBRequest authorizedRequest:^(NSDictionary *result, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            NSString *value = [NSString stringWithFormat:@"Bearer %@", [CBTokens accessToken]];
            [manager.requestSerializer setValue:value forHTTPHeaderField:@"Authorization"];
            NSString *url;
            if (!startUri) {
                url = @"https://api.coinbase.com/v2/accounts";
            } else {
                url = [NSString stringWithFormat:@"https://api.coinbase.com%@", startUri];
            }
            [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
                
                NSArray *accountsJson = [JSON objectForKey:@"data"];
                
                for (id account in accountsJson) {
                    NSDictionary *balanceJson = [account objectForKey:@"balance"];
                    CBAccountTwo *accountTwo = [[CBAccountTwo alloc] init];
                    accountTwo.name = [account objectForKey:@"name"];
                    accountTwo.id = [account objectForKey:@"id"];
                    accountTwo.type = [account objectForKey:@"type"];
                    accountTwo.primary = [[account objectForKey:@"primary"] boolValue];
                    accountTwo.balance = [balanceJson objectForKey:@"amount"];
                    accountTwo.currency = [balanceJson objectForKey:@"currency"];
                    [accounts addObject:accountTwo];
                }
                NSString *nextUri = [[JSON objectForKey:@"pagination"] objectForKey:@"next_uri"];
                if (nextUri && ![nextUri isEqual:[NSNull null]]) {
                    [self fetchAccounts:accounts withStartUri:nextUri withHandler:handler];
                } else {
                    handler([NSArray arrayWithArray:accounts] , nil);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                handler(nil, error);
            }];
        }
    }];
}

- (void)getAccounts:(AccountsHandler)handler {
    [self fetchAccounts:[[NSMutableArray alloc] init] withStartUri:nil withHandler:handler];
}

@end
