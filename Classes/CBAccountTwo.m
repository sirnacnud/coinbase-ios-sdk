//
//  CBAccountTwo.m
//  Pods
//
//  Created by Duncan Cunningham on 1/4/15.
//
//

#import "CBAccountTwo.h"
#import "CBRequest.h"
#include "CBTokens.h"
#import <AFNetworking/AFNetworking.h>

@implementation CBAccountTwo

- (void)getBalance:(BalanceHandler)handler {
    [CBRequest authorizedRequest:^(NSDictionary *result, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            [manager GET:[NSString stringWithFormat:@"https://api.coinbase.com/v1/accounts/%@/balance?access_token=%@", self.id, [CBTokens accessToken]] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
                
                handler([JSON objectForKey:@"amount"], nil);
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                handler(nil, error);
            }];
        }
    }];
}

- (void)fetchAccountChanges:(NSMutableArray*)changes withPage:(NSNumber*)page withHandler:(AccountsHandler)handler {
    [CBRequest authorizedRequest:^(NSDictionary *result, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            NSDictionary *params = @{@"page": page, @"account_id": self.id };
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            [manager GET:[NSString stringWithFormat:@"https://api.coinbase.com/v1/account_changes?access_token=%@", [CBTokens accessToken]] parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                
                NSArray *accountChanges = [JSON objectForKey:@"account_changes"];
                for (id accountJson in accountChanges) {
                    [changes addObject:accountJson];
                }
                
                if ([JSON objectForKey:@"num_pages"] > [JSON objectForKey:@"current_page"]) {
                    [self fetchAccountChanges:changes withPage:[NSNumber numberWithInt:[page intValue]+1] withHandler:handler];
                } else {
                    handler([NSArray arrayWithArray:changes] , nil);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                handler(nil, error);
            }];
        }
    }];
}

- (void)getAccountChanges:(AccountChangesHandler)handler {
    [self fetchAccountChanges:[[NSMutableArray alloc] init] withPage:[NSNumber numberWithInt:1] withHandler:handler];
}

@end
