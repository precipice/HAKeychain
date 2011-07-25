//
//  HAKeychain.m
//  HAKeychain
//
//  Created by Marc Hedlund on 7/23/11.
//  Copyright 2011 Hack Arts, LLC. All rights reserved.
//

#import "HAKeychain.h"


@implementation HAKeychain

+ (BOOL)createPassword:(NSString *)password
            forService:(NSString *)service
               account:(NSString *)account
              keychain:(SecKeychainRef)keychain
                 error:(NSError **)error {

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

    if (status != noErr && error != NULL) {
        *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                     code:status
                                 userInfo:nil];
    }

    return status == noErr;
}


@end
