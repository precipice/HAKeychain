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
    // Comment out this line and the GHAssertNoErr below, run the suite, and 
    // open up '/Applications/Utilities/Keychain Access.app' to see what the 
    // test cases look like in Keychain (or to debug a test).
    OSStatus err = SecKeychainDelete(testKeychain);

    // Run this even if the above is commented-out.
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


- (void)testNilPassword {
    NSError *error = nil;
    BOOL success = [HAKeychain createPassword:nil
                                   forService:@"nilpassservice"
                                      account:@"nilpassaccount"
                                     keychain:testKeychain
                                        error:&error];
    GHAssertFalse(success, @"Password creation succeeded but should have failed.");
    GHAssertNotNil(error, @"Should have an error, but there wasn't one.");
    GHAssertTrue([error code] == errSecParam, 
                 @"Expected a different error code but got %d.", [error code]);
}


- (void)testZeroLengthService {
    NSError *error = nil;
    BOOL success = [HAKeychain createPassword:@"zeroservicepass"
                                   forService:@""
                                      account:@"zeroserviceaccount"
                                     keychain:testKeychain
                                        error:&error];
    GHAssertFalse(success, @"Password creation succeeded but should have failed.");
    GHAssertNotNil(error, @"Should have an error, but there wasn't one.");
    GHAssertTrue([error code] == errSecParam, 
                 @"Expected a different error code but got %d.", [error code]);
}


- (void)testNilAccountAndError {
    BOOL success = [HAKeychain createPassword:@"nilacctpass"
                                   forService:@"nilacctservice"
                                      account:nil
                                     keychain:testKeychain
                                        error:nil];
    GHAssertFalse(success, @"Password creation succeeded but should have failed.");
}


- (void)testLocalizedErrorDescriptionOnDuplicate {
    NSString *password = @"localdescpass";
    NSString *service  = @"localdescservice";
    NSString *account  = @"localdescaccount";
    
    // First create should succeed.
    NSError *error = nil;
    BOOL success = [HAKeychain createPassword:password
                                   forService:service
                                      account:account
                                     keychain:testKeychain
                                        error:&error];
    GHAssertTrue(success, @"First password creation in duplicate failed.");
    
    // Second create should fail.
    BOOL success2 = [HAKeychain createPassword:password
                                    forService:service
                                       account:account
                                      keychain:testKeychain
                                         error:&error];
    GHAssertFalse(success2, @"Second password creation in duplicate succeeded, "
                  "but should have failed.");
    GHAssertTrue([error code] == errSecDuplicateItem, 
                 @"Expected a different error code but got %d.", [error code]);    
    GHAssertEqualStrings([error localizedDescription], 
                         @"That password already exists in the keychain.", 
                         @"Got an unexpected localized description.");
}


- (void)testPasswordRead {
    NSString *password = @"readpassword";
    NSString *service  = @"readservice";
    NSString *account  = @"readaccount";
    NSError *error = nil;
    
    BOOL success = [HAKeychain createPassword:password
                                   forService:service
                                      account:account
                                     keychain:testKeychain
                                        error:&error];
    GHAssertTrue(success, @"Password creation failed.");
    GHAssertNil(error, @"Should have no error, but there was one.");

    NSString *foundPassword = [HAKeychain findPasswordForService:service
                                                         account:account
                                                        keychain:testKeychain
                                                           error:&error];
    
    GHAssertNotNil(foundPassword, @"Found password should not be nil.");
    GHAssertNil(error, @"Find password error should be nil.");
    GHAssertEqualStrings(foundPassword, password, 
                         @"Found password doesn't match saved password.");
}

@end