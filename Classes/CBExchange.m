//
//  CBExchange.m
//  Handshake
//
//  Created by Josh Beal on 12/10/13.
//  Copyright (c) 2013 Handshake. All rights reserved.
//

#import "CBExchange.h"
#import "CBRequest.h"
#import "CBTokens.h"
#import <AFNetworking/AFNetworking.h>

@implementation CBExchange
+ (void)getTransfers:(CBResponseHandler)handler {
    [CBRequest authorizedRequest:^(NSDictionary *result, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            [manager GET:[NSString stringWithFormat:@"https://api.coinbase.com/v1/transfers?access_token=%@", [CBTokens accessToken]] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
                
                return handler(JSON, nil);
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                return handler(nil, error);
            }];
        }
    }];
}

+ (void)getBuyPrice:(NSString*)currency withCoin:(NSString*)coin withHandler:(PriceHandler)handler {
    NSString *pair = [NSString stringWithFormat:@"%@-%@", coin, currency];
    [CBRequest getRequest:[NSString stringWithFormat:@"https://api.coinbase.com/v2/prices/%@/buy", pair] withHandler:^(NSDictionary *result, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            NSDictionary *data = [result objectForKey:@"data"];
            handler([data objectForKey:@"amount"], nil);
        }
    }];
}

+ (void)getBuyPriceWithOutFee:(NSNumber*)qty withHandler:(PriceHandler)handler {
    [CBRequest getRequest:@"https://api.coinbase.com/v1/prices/buy" withHandler:^(NSDictionary *result, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            handler([[result objectForKey:@"subtotal"] objectForKey:@"amount"], nil);
        }
    }];
}

+ (void)getSellPrice:(NSString*)currency withCoin:(NSString*)coin withHandler:(PriceHandler)handler {
    NSString *pair = [NSString stringWithFormat:@"%@-%@", coin, currency];
    [CBRequest getRequest:[NSString stringWithFormat:@"https://api.coinbase.com/v2/prices/%@/sell", pair] withHandler:^(NSDictionary *result, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            NSDictionary *data = [result objectForKey:@"data"];
            handler([data objectForKey:@"amount"], nil);
        }
    }];
}

+ (void)getSellPriceWithOutFee:(NSNumber*)qty withHandler:(PriceHandler)handler {
    [CBRequest getRequest:@"https://api.coinbase.com/v1/prices/sell" withHandler:^(NSDictionary *result, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            handler([[result objectForKey:@"subtotal"] objectForKey:@"amount"], nil);
        }
    }];
}

+ (void)getSpotRate:(NSString*)currency withCoin:(NSString*)coin withHandler:(PriceHandler)handler {
    NSString *pair = [NSString stringWithFormat:@"%@-%@", coin, currency];
    [CBRequest getRequest:[NSString stringWithFormat:@"https://api.coinbase.com/v2/prices/%@/spot", pair] withHandler:^(NSDictionary *result, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            NSDictionary *data = [result objectForKey:@"data"];
            handler([data objectForKey:@"amount"], nil);
        }
    }];
}

+ (void)sellBitcoin:(NSNumber *)qty withHandler:(CBResponseHandler)handler {
    [CBRequest authorizedRequest:^(NSDictionary *result, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            NSDictionary *params = @{@"qty" : qty};

            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            [manager POST:[NSString stringWithFormat:@"https://api.coinbase.com/v1/sells?access_token=%@", [CBTokens accessToken]] parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                
                handler(JSON, nil);
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                handler(nil, error);
            }];
        }
    }];
}

+ (void)buyBitcoin:(NSNumber *)qty withHandler:(CBResponseHandler)handler {
    [CBRequest authorizedRequest:^(NSDictionary *result, NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            NSDictionary *params = @{@"qty" : qty};
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            [manager POST:[NSString stringWithFormat:@"https://api.coinbase.com/v1/buys?access_token=%@", [CBTokens accessToken]] parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                
                handler(JSON, nil);
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                handler(nil, error);
            }];
        }
    }];
}

+ (void)getExchangeRatesForCurrency:(NSString *)currency withHandler:(CBResponseHandler)handler {
    [CBRequest getRequest:[NSString stringWithFormat:@"https://api.coinbase.com/v2/exchange-rates?currency=%@", currency] withHandler:^(NSDictionary *result, NSError *error) {
        NSArray *data = [result objectForKey:@"data"];
        handler(data, error);
    }];
}

+ (void)getSupportedCurrencies:(CurrenciesHandler)handler {
    [CBRequest getRequest:@"https://api.coinbase.com/v2/currencies" withHandler:^(id result, NSError *error) {
        NSArray *data = [result objectForKey:@"data"];
        handler(data, error);
    }];
}

@end
