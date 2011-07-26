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


#pragma mark -
#pragma mark Test keychain lifecycle

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


#pragma mark -
#pragma mark Password creation tests

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


#pragma mark -
#pragma mark Password read tests

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


- (void)testReadWithDifferentAccount {
    // Sanity check a slight difference in saved passwords.
    NSString *service  = @"readdiffservice";
    NSError *error = nil;
    
    BOOL created1 = [HAKeychain createPassword:@"readdiffpw1"
                                    forService:service
                                       account:@"readdiffacct1"
                                      keychain:testKeychain
                                         error:&error];
    GHAssertTrue(created1, @"Password creation failed.");
    GHAssertNil(error, @"Should have no error, but there was one.");
    
    BOOL created2 = [HAKeychain createPassword:@"readdiffpw2"
                                    forService:service
                                       account:@"readdiffacct2"
                                      keychain:testKeychain
                                         error:&error];
    GHAssertTrue(created2, @"Password creation failed.");
    GHAssertNil(error, @"Should have no error, but there was one.");
    
    NSString *foundPassword = [HAKeychain findPasswordForService:service
                                                         account:@"readdiffacct1"
                                                        keychain:testKeychain
                                                           error:&error];
    
    GHAssertNotNil(foundPassword, @"Found password should not be nil.");
    GHAssertNil(error, @"Find password error should be nil.");
    GHAssertEqualStrings(foundPassword, @"readdiffpw1", 
                         @"Found password doesn't match saved password.");    
}


#pragma mark -
#pragma mark Password update tests

- (void)testPasswordUpdate {
    NSString *service = @"updateservice";
    NSString *account = @"updateaccount";
    NSError *error = nil;
    
    BOOL created = [HAKeychain createPassword:@"updatepass1"
                                   forService:service
                                      account:account
                                     keychain:testKeychain
                                        error:&error];
    GHAssertTrue(created, @"Password creation failed.");
    GHAssertNil(error, @"Should have no error, but there was one.");
    
    BOOL updated = [HAKeychain updatePassword:@"updatepass2"
                                   forService:service
                                      account:account
                                     keychain:testKeychain
                                        error:&error];
    GHAssertTrue(updated, @"Password update failed; error = %@.",
                 [error localizedDescription]);
    GHAssertNil(error, @"Should have no error, but there was one.");
    
    NSString *foundPassword = [HAKeychain findPasswordForService:service
                                                         account:account
                                                        keychain:testKeychain
                                                           error:&error];
    
    GHAssertEqualStrings(foundPassword, @"updatepass2", 
                         @"Found password should be updated.");
    GHAssertNil(error, @"Find password error should be nil.");
}


- (void)testUpdateNonexistentPassword {
    NSError *error = nil;
    BOOL updated = [HAKeychain updatePassword:@"nonexistantpassword"
                                   forService:@"nonexistantservice"
                                      account:@"nonexistantaccount"
                                     keychain:testKeychain
                                        error:&error];
    GHAssertFalse(updated, 
                  @"Password update succeeded but should have failed.");
    GHAssertNotNil(error, @"Should have an error, but there wasn't one.");
    GHAssertTrue([error code] == errSecItemNotFound, 
                 @"Unexpected error message: code %d", [error code]);
}


#pragma mark -
#pragma mark Password deletion tests

- (void)testPasswordDelete {
    NSString *service = @"deleteservice";
    NSString *account = @"deleteaccount";
    NSError *error = nil;
    
    BOOL created = [HAKeychain createPassword:@"deletepass"
                                   forService:service
                                      account:account
                                     keychain:testKeychain
                                        error:&error];
    GHAssertTrue(created, @"Password creation failed.");
    GHAssertNil(error, @"Should have no error, but there was one.");
    
    BOOL deleted = [HAKeychain deletePasswordForService:service
                                                account:account
                                               keychain:testKeychain
                                                  error:&error];
    GHAssertTrue(deleted, @"Password deletion failed.");
    GHAssertNil(error, @"Should have no error, but there was one.");
    
    NSString *foundPassword = [HAKeychain findPasswordForService:service
                                                         account:account
                                                        keychain:testKeychain
                                                           error:&error];
    
    GHAssertNil(foundPassword, @"Found password should be nil.");
    GHAssertNotNil(error, @"Find password error should not be nil.");
    GHAssertTrue([error code] == errSecItemNotFound, 
                 @"Got an unexpected error code.");
    GHAssertEqualStrings([error localizedDescription], 
                         @"The item could not be found in the keychain.",
                         @"Got an unexpected error description.");    

}

- (void)testDeleteNonexistentPassword {
    NSError *error = nil;
    BOOL deleted = [HAKeychain deletePasswordForService:@"nonexistantservice"
                                                account:@"nonexistantaccount"
                                               keychain:testKeychain
                                                  error:&error];
    GHAssertFalse(deleted, 
                  @"Password deletion succeeded but should have failed.");
    GHAssertNotNil(error, @"Should have an error, but there wasn't one.");
    GHAssertTrue([error code] == errSecItemNotFound, 
                   @"Unexpected error message: code %d", [error code]);
}


#pragma mark -
#pragma mark Error tests

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


@end