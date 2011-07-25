//
//  HAKeychain.m
//  HAKeychain
//
//  Created by Marc Hedlund on 7/23/11.
//  Copyright 2011 Hack Arts, LLC. All rights reserved.
//

#import "HAKeychain.h"

@interface HAKeychain (PrivateMethods) 
+ (BOOL)validService:(NSString *)service account:(NSString *)account;
+ (void)setCode:(NSInteger)code error:(NSError **)error;
@end


@implementation HAKeychain

+ (BOOL)validService:(NSString *)service account:(NSString *)account {
    if (service == NULL || [service length] == 0 ||
        account == NULL || [account length] == 0) {
        return NO;
    }
    return YES;
}


+ (void)setCode:(NSInteger)code error:(NSError **)error {
    if (error != NULL) {
        *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                     code:code
                                 userInfo:nil];
    }    
}


+ (BOOL)createPassword:(NSString *)password
            forService:(NSString *)service
               account:(NSString *)account
              keychain:(SecKeychainRef)keychain
                 error:(NSError **)error {
    
    if (password == NULL || ![HAKeychain validService:service account:account]) {
        [HAKeychain setCode:errSecParam error:error];
        return NO;
    }

    const char *passwordUTF8 = [password UTF8String];
    const char *serviceUTF8  = [service UTF8String];
    const char *accountUTF8  = [account UTF8String];
    SecKeychainItemRef item = nil;

    OSStatus status = SecKeychainAddGenericPassword(keychain,
                                                    (UInt32)strlen(serviceUTF8),
                                                    serviceUTF8,
                                                    (UInt32)strlen(accountUTF8),
                                                    accountUTF8,
                                                    (UInt32)strlen(passwordUTF8),
                                                    passwordUTF8,
                                                    &item);
    if (item) CFRelease(item);

    if (status != noErr) {
        [HAKeychain setCode:status error:error];
    }

    return status == noErr;
}


@end
