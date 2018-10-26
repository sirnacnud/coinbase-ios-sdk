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

- (void)fetchAccountChanges:(NSMutableArray*)changes withStartUri:(NSString*)startUri withLimit:(NSNumber*)limit withHandler:(AccountsHandler)handler {
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
                url = [NSString stringWithFormat:@"https://api.coinbase.com/v2/accounts/%@/transactions", self.id];
            } else {
                url = [NSString stringWithFormat:@"https://api.coinbase.com%@", startUri];
            }
            [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
                
                NSArray *transactionsJson = [JSON objectForKey:@"data"];
                
                for (id transaction in transactionsJson) {
                    if (limit != nil && changes.count == [limit integerValue]) {
                        handler([NSArray arrayWithArray:changes] , nil);
                        return;
                    }
                    [changes addObject:transaction];
                }
                NSString *nextUri = [[JSON objectForKey:@"pagination"] objectForKey:@"next_uri"];
                if (nextUri && ![nextUri isEqual:[NSNull null]]) {
                    [self fetchAccountChanges:changes withStartUri:nextUri withLimit:limit withHandler:handler];
                } else {
                    handler([NSArray arrayWithArray:changes] , nil);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                handler(nil, error);
            }];
        }
    }];
}

- (void)getAccountChangesSinceTranscationId:(NSString*)transcationId withLimit:(NSNumber*)limit withHandler:(AccountChangesHandler)handler {
    NSString *startUri;
    if( transcationId != nil ) {
        startUri = [NSString stringWithFormat:@"/v2/accounts/%@/transactions?&ending_before=%@", self.id, transcationId];
    }
    [self fetchAccountChanges:[[NSMutableArray alloc] init] withStartUri:startUri withLimit:limit withHandler:handler];
}

@end
