//
//  MTKeyChainManager.h
//  KeyChainTest
//
//  Created by MenThu on 2018/6/12.
//  Copyright © 2018年 csdc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTKeyChainManager : NSObject

/**
 *  指定服务，可以为nil
 */
- (instancetype)initWithService:(NSString *)service;

/**
 *  若当前账号密码不存在，则新增
 *  若存在，则更新
 */
- (BOOL)saveAccount:(NSString *)account withPassword:(NSString *)password;

/**
 *  查找账号对应的密码，可能会返回为nil
 */
- (NSString *)passWordForAccount:(NSString *)account;

/**
 *  删除账号密码
 */
- (BOOL)deleteAccount:(NSString *)account;

@end
