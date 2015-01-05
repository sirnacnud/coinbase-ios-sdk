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

@end
