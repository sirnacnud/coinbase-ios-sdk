//
//  CBHandlers.h
//  Pods
//
//  Created by Duncan Cunningham on 1/4/15.
//
//

#ifndef CBHandlers_h
#define CBHandlers_h

@class CBTransaction;
@class CBAccount;
@class CBUser;
@class CBUserTwo;

typedef void (^TransactionsHandler)(NSArray *transactions, NSError *error);
typedef void (^BalanceHandler)(NSString *balance, NSError *error);
typedef void (^AddressHandler)(NSString *address, NSError *error);
typedef void (^AddressListHandler)(NSArray *addressList, NSError *error);

typedef void (^PriceHandler)(NSString *price, NSError *error);
typedef void (^CurrenciesHandler)(NSArray* currencies, NSError *error);

typedef void (^CBResponseHandler)(id result, NSError* error);

typedef void (^TransactionHandler)(CBTransaction *transaction, NSError *error);
typedef void (^RequestActionHandler)(BOOL success, NSError *error);

typedef void (^AccountHandler)(CBAccount *account, NSError *error);
typedef void (^LoginHandler)(NSError *error);

typedef void (^UserHandler)(CBUser *user, NSError *error);
typedef void (^UserTwoHandler)(CBUserTwo *user, NSError *error);
typedef void (^AccountsHandler)(NSArray *accounts, NSError *error);

typedef void (^AccountChangesHandler)(NSArray *changes, NSError *error);

#endif
