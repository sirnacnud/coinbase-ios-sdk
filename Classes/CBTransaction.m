//
//  CBTransaction.m
//  Handshake
//
//  Created by Josh Beal on 12/10/13.
//  Copyright (c) 2013 Handshake. All rights reserved.
//

#import "CBTransaction.h"
#import "Coinbase.h"

@implementation CBTransaction

+ (CBTransaction *)parseTransaction:(id)JSON forAccount:(CBAccount*)account {
    CBTransaction *transaction = [[CBTransaction alloc] init];
    NSMutableDictionary *tDict = [JSON objectForKey:@"transaction"];
    transaction.amount = [[tDict objectForKey:@"amount"] objectForKey:@"amount"];
    transaction.sender = [[[tDict objectForKey:@"sender"] objectForKey:@"email"] isEqualToString:account.email];
    transaction.name = transaction.sender ? [[tDict objectForKey:@"recipient"] objectForKey:@"name"] : [[tDict objectForKey:@"sender"] objectForKey:@"name"];
    if (!([tDict objectForKey:@"hsh"] == [NSNull null])) {
        transaction.hash = [tDict objectForKey:@"hsh"];
    }
    transaction.email = transaction.sender ? [[tDict objectForKey:@"recipient"] objectForKey:@"email"] : [[tDict objectForKey:@"sender"] objectForKey:@"email"];
    if (!transaction.name) {
        transaction.name = [tDict objectForKey:@"recipient_address"];
    }
    transaction.transactionId = [tDict objectForKey:@"id"];
    transaction.timestamp = [tDict objectForKey:@"created_at"];
    transaction.request = [[tDict objectForKey:@"request"] boolValue];
    return transaction;
}

+ (void)send:(NSNumber*)amount to:(NSString*)address withNotes:(NSString*)notes withHandler:(TransactionHandler)handler {
    [Coinbase getAccount:^(CBAccount *account, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            [CBRequest authorizedRequest:^(NSDictionary *result, NSError *error) {
                AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://coinbase.com"]];
                [httpClient setParameterEncoding:AFJSONParameterEncoding];
                NSDictionary *params = @{@"transaction" : @{
                                                 @"to": address,
                                                 @"amount": amount,
                                                 @"notes": notes
                                                 }};
                NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                                        path:[NSString stringWithFormat:@"https://coinbase.com/api/v1/transactions/send_money?access_token=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]]
                                                                  parameters:params];
                httpClient.parameterEncoding = AFJSONParameterEncoding;
                AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    handler([self parseTransaction:JSON forAccount:account], nil);
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    handler(nil, error);
                }];
                [operation start];
            }];
        }
    }];
}

+ (void)request:(NSNumber*)amount from:(NSString*)address withNotes:(NSString*)notes withHandler:(TransactionHandler)handler {
    [Coinbase getAccount:^(CBAccount *account, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            [CBRequest authorizedRequest:^(NSDictionary *result, NSError *error) {
                AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://coinbase.com"]];
                [httpClient setParameterEncoding:AFJSONParameterEncoding];
                NSDictionary *params = @{@"transaction" : @{
                                                 @"from": address,
                                                 @"amount": amount,
                                                 @"notes": notes
                                                 }};
                NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                                        path:[NSString stringWithFormat:@"https://coinbase.com/api/v1/transactions/request_money?access_token=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]]
                                                                  parameters:params];
                httpClient.parameterEncoding = AFJSONParameterEncoding;
                AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    handler([self parseTransaction:JSON forAccount:account], nil);
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    handler(nil, error);
                }];
                [operation start];
            }];
        }
    }];
}

+ (void)resend:(NSString*)requestId withHandler:(RequestActionHandler)handler {
    [Coinbase getAccount:^(CBAccount *account, NSError *error) {
        if (error) {
            handler(NO, error);
        } else {
            [CBRequest authorizedRequest:^(NSDictionary *result, NSError *error) {
                AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://coinbase.com"]];
                [httpClient setParameterEncoding:AFJSONParameterEncoding];
                NSMutableURLRequest *request = [httpClient requestWithMethod:@"PUT"
                                                                        path:[NSString stringWithFormat:@"https://coinbase.com/api/v1/transactions/%@/resend_request?access_token=%@", requestId, [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]]
                                                                  parameters:nil];
                httpClient.parameterEncoding = AFJSONParameterEncoding;
                AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    handler([[JSON objectForKey:@"success"] boolValue], nil);
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    handler(NO, error);
                }];
                [operation start];
            }];
        }
    }];
}

+ (void)cancel:(NSString*)requestId withHandler:(RequestActionHandler)handler {
    [Coinbase getAccount:^(CBAccount *account, NSError *error) {
        if (error) {
            handler(NO, error);
        } else {
            [CBRequest authorizedRequest:^(NSDictionary *result, NSError *error) {
                AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://coinbase.com"]];
                [httpClient setParameterEncoding:AFJSONParameterEncoding];
                NSMutableURLRequest *request = [httpClient requestWithMethod:@"DELETE"
                                                                        path:[NSString stringWithFormat:@"https://coinbase.com/api/v1/transactions/%@/cancel_request?access_token=%@", requestId, [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]]
                                                                  parameters:nil];
                httpClient.parameterEncoding = AFJSONParameterEncoding;
                AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    handler([[JSON objectForKey:@"success"] boolValue], nil);
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    handler(NO, error);
                }];
                [operation start];
            }];
        }
    }];
}

+ (void)complete:(NSString*)requestId withHandler:(TransactionHandler)handler {
    [Coinbase getAccount:^(CBAccount *account, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            [CBRequest authorizedRequest:^(NSDictionary *result, NSError *error) {
                AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://coinbase.com"]];
                [httpClient setParameterEncoding:AFJSONParameterEncoding];
                NSMutableURLRequest *request = [httpClient requestWithMethod:@"PUT"
                                                                        path:[NSString stringWithFormat:@"https://coinbase.com/api/v1/transactions/%@/complete_request?access_token=%@", requestId, [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]]
                                                                  parameters:nil];
                httpClient.parameterEncoding = AFJSONParameterEncoding;
                AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    handler([self parseTransaction:JSON forAccount:account], nil);
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    handler(nil, error);
                }];
                [operation start];
            }];
        }
    }];
}

@end
