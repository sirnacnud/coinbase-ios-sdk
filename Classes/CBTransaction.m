//
//  CBTransaction.m
//  Handshake
//
//  Created by Josh Beal on 12/10/13.
//  Copyright (c) 2013 Handshake. All rights reserved.
//

#import "CBTransaction.h"
#import "CBAccount.h"
#import "CBRequest.h"
#import "CBTokens.h"
#import "CBUser.h"
#import "Coinbase.h"
#import <AFNetworking/AFNetworking.h>

@implementation CBTransaction

+ (CBTransaction *)parseTransaction:(id)JSON forUser:(CBUser*)user {
    CBTransaction *transaction = [[CBTransaction alloc] init];
    transaction.success = [[JSON objectForKey:@"success"] boolValue];
    if (transaction.success) {
        NSMutableDictionary *tDict = [JSON objectForKey:@"transaction"];
        transaction.amount = [[tDict objectForKey:@"amount"] objectForKey:@"amount"];
        transaction.sender = [[[tDict objectForKey:@"sender"] objectForKey:@"email"] isEqualToString:user.email];
        transaction.name = transaction.sender ? [[tDict objectForKey:@"recipient"] objectForKey:@"name"] : [[tDict objectForKey:@"sender"] objectForKey:@"name"];
        if (!([tDict objectForKey:@"hsh"] == [NSNull null])) {
            transaction.hsh = [tDict objectForKey:@"hsh"];
        }
        transaction.email = transaction.sender ? [[tDict objectForKey:@"recipient"] objectForKey:@"email"] : [[tDict objectForKey:@"sender"] objectForKey:@"email"];
        if (!transaction.name) {
            transaction.name = [tDict objectForKey:@"recipient_address"];
        }
        transaction.transactionId = [tDict objectForKey:@"id"];
        transaction.timestamp = [tDict objectForKey:@"created_at"];
        transaction.request = [[tDict objectForKey:@"request"] boolValue];
    } else {
        transaction.errors = [JSON objectForKey:@"errors"];
    }
    return transaction;
}

+ (void)send:(NSNumber*)amount to:(NSString*)address withNotes:(NSString*)notes withHandler:(TransactionHandler)handler {
    [self send:amount withCurrency:@"BTC" to:address withNotes:notes withHandler:handler];
}

+ (void)send:(NSNumber*)amount withCurrency:(NSString*)currency to:(NSString*)address withNotes:(NSString*)notes withHandler:(TransactionHandler)handler {
    [self send:amount withCurrency:currency to:address withNotes:notes withFee:[NSNumber numberWithInt:0] withHandler:handler];
}

+ (void)send:(NSNumber*)amount withCurrency:(NSString*)currency to:(NSString*)address withNotes:(NSString*)notes withFee:(NSNumber*)fee withHandler:(TransactionHandler)handler {
    [Coinbase getUser:^(CBUser *user, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            [CBRequest authorizedRequest:^(NSDictionary *result, NSError *error) {
                NSDictionary *params = @{@"transaction" : @{
                                                 @"to": address,
                                                 @"amount_string": amount,
                                                 @"amount_currency_iso": currency,
                                                 @"notes": notes,
                                                 @"user_fee":fee
                                                 }};
                
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.responseSerializer = [AFJSONResponseSerializer serializer];
                [manager POST:[NSString stringWithFormat:@"https://api.coinbase.com/v1/transactions/send_money?access_token=%@", [CBTokens accessToken]] parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                    handler([self parseTransaction:JSON forUser:user], nil);
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    handler(nil, error);
                }];
            }];
        }
    }];
}

+ (void)request:(NSNumber*)amount from:(NSString*)address withNotes:(NSString*)notes withHandler:(TransactionHandler)handler {
    [self request:amount withCurrency:@"BTC" from:address withNotes:notes withHandler:handler];
}

+ (void)request:(NSNumber*)amount withCurrency:(NSString*)currency from:(NSString*)address withNotes:(NSString*)notes withHandler:(TransactionHandler)handler {
    [Coinbase getUser:^(CBUser *user, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            [CBRequest authorizedRequest:^(NSDictionary *result, NSError *error) {
                NSDictionary *params = @{@"transaction" : @{
                                                 @"from": address,
                                                 @"amount_string": amount,
                                                 @"amount_currency_iso": currency,
                                                 @"notes": notes
                                                 }};

                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.responseSerializer = [AFJSONResponseSerializer serializer];
                [manager POST:[NSString stringWithFormat:@"https://api.coinbase.com/v1/transactions/request_money?access_token=%@", [CBTokens accessToken]] parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                    
                    handler([self parseTransaction:JSON forUser:user], nil);
   
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    handler(nil, error);
                }];
            }];
        }
    }];
}

+ (void)resend:(NSString*)requestId withHandler:(RequestActionHandler)handler {
    [CBRequest authorizedRequest:^(NSDictionary *result, NSError *error) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        [manager PUT:[NSString stringWithFormat:@"https://api.coinbase.com/v1/transactions/%@/resend_request?access_token=%@", requestId, [CBTokens accessToken]] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
            
            handler([[JSON objectForKey:@"success"] boolValue], nil);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            handler(NO, error);
        }];
    }];
}

+ (void)cancel:(NSString*)requestId withHandler:(RequestActionHandler)handler {
    [CBRequest authorizedRequest:^(NSDictionary *result, NSError *error) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        [manager DELETE:[NSString stringWithFormat:@"https://api.coinbase.com/v1/transactions/%@/cancel_request?access_token=%@", requestId, [CBTokens accessToken]] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
            
            handler([[JSON objectForKey:@"success"] boolValue], nil);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            handler(NO, error);
        }];
    }];
}

+ (void)complete:(NSString*)requestId withHandler:(TransactionHandler)handler {
    [Coinbase getUser:^(CBUser *user, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            [CBRequest authorizedRequest:^(NSDictionary *result, NSError *error) {
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.responseSerializer = [AFJSONResponseSerializer serializer];
                [manager PUT:[NSString stringWithFormat:@"https://api.coinbase.com/v1/transactions/%@/complete_request?access_token=%@", requestId, [CBTokens accessToken]] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
                    
                    handler([self parseTransaction:JSON forUser:user], nil);
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    handler(nil, error);
                }];
            }];
        }
    }];
}

@end
