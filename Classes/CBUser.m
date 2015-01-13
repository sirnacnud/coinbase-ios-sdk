//
//  CBUser.m
//  Pods
//
//  Created by Duncan Cunningham on 1/4/15.
//
//

#import "CBUser.h"
#import "CBAccountTwo.h"
#import "CBRequest.h"
#import "CBTokens.h"

@implementation CBUser

- (void)fetchAccounts:(NSMutableArray*)accounts withPage:(NSNumber*)page withHandler:(AccountsHandler)handler {
    [CBRequest authorizedRequest:^(NSDictionary *result, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            [manager GET:[NSString stringWithFormat:@"https://api.coinbase.com/v1/accounts?access_token=%@", [CBTokens accessToken]] parameters:@{@"page":page} success:^(AFHTTPRequestOperation *operation, id JSON) {
                
                NSArray *accountsJson = [JSON objectForKey:@"accounts"];
                
                for (id account in accountsJson) {
                    CBAccountTwo *accountTwo = [[CBAccountTwo alloc] init];
                    accountTwo.name = [account objectForKey:@"name"];
                    accountTwo.id = [account objectForKey:@"id"];
                    accountTwo.type = [account objectForKey:@"type"];
                    accountTwo.primary = [[account objectForKey:@"primary"] boolValue];
                    [accounts addObject:accountTwo];
                }
                
                if ([JSON objectForKey:@"num_pages"] > [JSON objectForKey:@"current_page"]) {
                    [self fetchAccounts:accounts withPage:[NSNumber numberWithInt:[page intValue]+1] withHandler:handler];
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
    [self fetchAccounts:[[NSMutableArray alloc] init] withPage:[NSNumber numberWithInt:1] withHandler:handler];
}

- (void)getContacts:(CBResponseHandler)handler {
    [CBRequest authorizedRequest:^(NSDictionary *result, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            [manager GET:[NSString stringWithFormat:@"https://api.coinbase.com/v1/contacts?access_token=%@", [CBTokens accessToken]] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
                
                handler(JSON, nil);
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                handler(nil, error);
            }];
        }
    }];
}

@end
