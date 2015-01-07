//
//  CBAccountTwo.h
//  Pods
//
//  Created by Duncan Cunningham on 1/4/15.
//
//

#import <Foundation/Foundation.h>

#include "CBHandlers.h"

@interface CBAccountTwo : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *type;
@property (nonatomic) BOOL primary;

- (void)getBalance:(BalanceHandler)handler;
- (void)getAccountChanges:(AccountChangesHandler)handler;

@end
