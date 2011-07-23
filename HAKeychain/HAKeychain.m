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
              keychain:(SecKeychainRef *)keychain
                 error:(NSError **)error {
    NSLog(@"Password creation not yet implemented.");
    return NO;
}


@end
