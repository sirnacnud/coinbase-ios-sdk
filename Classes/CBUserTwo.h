//
//  CBUserTwo.h
//  Pods
//
//  Created by Duncan Cunningham on 10/16/18.
//  Copyright © 2018 Duncan Cunningham. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CBHandlers.h"

NS_ASSUME_NONNULL_BEGIN

@interface CBUserTwo : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *avatar;

- (void)getAccounts:(AccountsHandler)handler;

@end

NS_ASSUME_NONNULL_END
