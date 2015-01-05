//
//  CBUser.h
//  Pods
//
//  Created by Duncan Cunningham on 1/4/15.
//
//

#import <Foundation/Foundation.h>

#import "CBHandlers.h"

@interface CBUser : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *balance;
@property (nonatomic, strong) NSString *cbId;
@property (nonatomic, strong) NSString *nativeCurrency;
@property (nonatomic, strong) NSString *timeZone;
@property (nonatomic, strong) NSString *buyLevel;
@property (nonatomic, strong) NSString *buyLimit;
@property (nonatomic, strong) NSString *sellLevel;
@property (nonatomic, strong) NSString *sellLimit;

- (void)getAccounts:(AccountsHandler)handler;
- (void)getContacts:(CBResponseHandler)handler;

@end
