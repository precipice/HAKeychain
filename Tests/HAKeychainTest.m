//
//  KeychainTest.m
//  HAKeychain
//
//  Created by Marc Hedlund on 7/22/11.
//  Copyright 2011 Hack Arts, LLC. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import <Security/Security.h>
#import "HAKeychain.h"

@interface HAKeychainTest : GHTestCase { 
    SecKeychainRef testKeychain;
}
@end


@implementation HAKeychainTest

- (void)setUpClass {
    GHTestLog(@"Creating private keychain for test suite to use.");
    const char *pathName = "/tmp/HAKeychain-Test.keychain";
    void *password = "hakeychaintest";
    
    OSStatus err = SecKeychainCreate(pathName,
                                     (UInt32) strlen(password),
                                     password,
                                     NO,
                                     NULL,
                                     &testKeychain);
    GHAssertNoErr(err, @"Failed to create test keychain");
}


- (void)tearDownClass {
    GHTestLog(@"Deleting test suite keychain.");
    OSStatus err = SecKeychainDelete(testKeychain);
    CFRelease(testKeychain);
    GHAssertNoErr(err, @"Failed to delete test keychain");    
}


- (void)testPasswordCreate {
    NSError *error = nil;
    BOOL success = [HAKeychain createPassword:@"testpass"
                                   forService:@"testservice"
                                      account:@"testaccount"
                                     keychain:testKeychain
                                        error:&error];
    GHAssertTrue(success, @"Password creation failed.");
    GHAssertNil(error, @"Should have no error, but there was one.");
}


- (void)testCreateDuplicatePassword {
    NSString *password = @"dupepass";
    NSString *service  = @"dupeservice";
    NSString *account  = @"dupeaccount";
    
    // First create should succeed.
    NSError *error = nil;
    BOOL success = [HAKeychain createPassword:password
                                   forService:service
                                      account:account
                                     keychain:testKeychain
                                        error:&error];
    GHAssertTrue(success, @"First password creation in duplicate failed.");
    GHAssertNil(error, @"Should have no error, but there was one.");
    
    // Second create should fail.
    BOOL success2 = [HAKeychain createPassword:password
                                    forService:service
                                       account:account
                                      keychain:testKeychain
                                         error:&error];
    GHAssertFalse(success2, @"Second password creation in duplicate succeeded, "
                             "but should have failed.");
    GHAssertNotNil(error, @"Should have an error, but there wasn't one.");
    GHAssertTrue([error code] == errSecDuplicateItem, 
                 @"Expected a different error code but got %d.", [error code]);
}


- (void)testIgnoreError {
    NSString *password = @"noerrpass";
    NSString *service  = @"noerrservice";
    NSString *account  = @"noerraccount";
    
    // First create should succeed.
    BOOL success = [HAKeychain createPassword:password
                                   forService:service
                                      account:account
                                     keychain:testKeychain
                                        error:nil];
    GHAssertTrue(success, @"First password creation in ignore error failed.");
    
    // Second create should fail.
    BOOL success2 = [HAKeychain createPassword:password
                                    forService:service
                                       account:account
                                      keychain:testKeychain
                                         error:nil];
    GHAssertFalse(success2, @"Second password creation in ignore succeeded, "
                             "but should have failed.");
}

@end