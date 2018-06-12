//
//  MTKeyChainManager.m
//  KeyChainTest
//
//  Created by MenThu on 2018/6/12.
//  Copyright © 2018年 csdc. All rights reserved.
//

#import "MTKeyChainManager.h"
//#import <Security/Security.h>

@interface MTKeyChainManager ()

@property (nonatomic, strong) NSMutableDictionary *keyChainAttribute;

@end

@implementation MTKeyChainManager

#pragma mark - Life Cycle
- (instancetype)initWithService:(NSString *)service{
    if (self = [super init]) {
        self.keyChainAttribute = @{}.mutableCopy;
        //指定访问权限
        self.keyChainAttribute[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlocked;
        //指定访问用户（缓存一般密码）
        self.keyChainAttribute[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
        //指定用途
        if ([service isKindOfClass:[NSString class]] && service.length > 0) {
            self.keyChainAttribute[(__bridge id)kSecAttrService] = service;
        }else{
            self.keyChainAttribute[(__bridge id)kSecAttrService] = @"MaopaoUserPassword";
        }
    }
    return self;
}

#pragma mark - Public
- (BOOL)saveAccount:(NSString *)account withPassword:(NSString *)password{
    NSAssert([MTKeyChainManager isStringExist:password] && [MTKeyChainManager isStringExist:account], @"");
    NSString *returnPassword = [self private_selectPasswordForAccount:account];
    if ([MTKeyChainManager isStringExist:returnPassword]) {
        //账号密码已存在,更新
        return [self private_updatePasswordForAccount:account password:password];
    }else{
        //不存在,新增
        return [self private_addAccount:account withPassword:password];
    }
}

- (NSString *)passWordForAccount:(NSString *)account{
    NSAssert([MTKeyChainManager isStringExist:account], @"");
    return [self private_selectPasswordForAccount:account];
}

- (BOOL)deleteAccount:(NSString *)account{
    NSAssert([MTKeyChainManager isStringExist:account], @"");
    NSString *passWord = [self private_selectPasswordForAccount:account];
    if ([MTKeyChainManager isStringExist:passWord]) {
        //账号密码存在,调用删除
        return [self private_deletePasswordForAccount:account];
    }
    return YES;
}

#pragma mark - Private
/**
 *  增
 */
- (BOOL)private_addAccount:(NSString *)account withPassword:(NSString *)password{
    NSData *passWordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    self.keyChainAttribute[(__bridge id)kSecAttrAccount] = account;
    self.keyChainAttribute[(__bridge id)kSecValueData] = passWordData;
    BOOL isSucc = (SecItemAdd((__bridge CFDictionaryRef)self.keyChainAttribute, nil) == noErr);
    [self.keyChainAttribute removeObjectForKey:(__bridge id)kSecAttrAccount];
    [self.keyChainAttribute removeObjectForKey:(__bridge id)kSecValueData];
    return isSucc;
}

/**
 *  删
 */
- (BOOL)private_deletePasswordForAccount:(NSString *)account{
    self.keyChainAttribute[(__bridge id)kSecAttrAccount] = account;
    BOOL isSucc = (SecItemDelete((__bridge CFDictionaryRef)self.keyChainAttribute) == noErr);
    [self.keyChainAttribute removeObjectForKey:(__bridge id)kSecAttrAccount];
    return isSucc;
}

/**
 *  改
 */
- (BOOL)private_updatePasswordForAccount:(NSString *)account password:(NSString *)password{
    self.keyChainAttribute[(__bridge id)kSecAttrAccount] = account;
    NSMutableDictionary *updateAttribute = @{}.mutableCopy;
    updateAttribute[(__bridge id)kSecValueData] = [password dataUsingEncoding:NSUTF8StringEncoding];
    BOOL isSucc = (SecItemUpdate((__bridge CFDictionaryRef)self.keyChainAttribute, (__bridge CFDictionaryRef)updateAttribute) == noErr);
    [self.keyChainAttribute removeObjectForKey:(__bridge id)kSecAttrAccount];
    return isSucc;
}

/**
 *  查
 */
- (NSString *)private_selectPasswordForAccount:(NSString *)account{
    //查该条item的全量数据
    self.keyChainAttribute[(__bridge id)kSecReturnRef] = @(YES);
    //返回类型为data
    self.keyChainAttribute[(__bridge id)kSecReturnData] = @(YES);
    //返回条数为一条
    self.keyChainAttribute[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    //账号
    self.keyChainAttribute[(__bridge id)kSecAttrAccount] = account;
    NSString *password = nil;
    CFTypeRef dataTypeRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)self.keyChainAttribute, &dataTypeRef);
    if (status == errSecSuccess) {
        NSDictionary *dict = (__bridge NSDictionary *)dataTypeRef;
#if DEBUG
        NSLog(@"==result:%@", dict);
#endif
        NSData *data = dict[(__bridge NSData*)kSecValueData];
        password = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    [self.keyChainAttribute removeObjectForKey:(__bridge id)kSecReturnRef];
    [self.keyChainAttribute removeObjectForKey:(__bridge id)kSecReturnData];
    [self.keyChainAttribute removeObjectForKey:(__bridge id)kSecMatchLimit];
    [self.keyChainAttribute removeObjectForKey:(__bridge id)kSecAttrAccount];
    return password;
}

/**
 *  检查字符串是否有效
 */
+ (BOOL)isStringExist:(NSString *)string{
    if ([string isKindOfClass:[NSString class]] && string.length > 0) {
        return YES;
    }else{
        return NO;
    }
}

@end
