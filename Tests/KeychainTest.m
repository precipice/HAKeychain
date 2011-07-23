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
    UInt32 passwordLength = (UInt32) strlen(password);
    Boolean promptUser = NO;
    
    
    OSStatus err = SecKeychainCreate(pathName,
                                     passwordLength,
                                     password,
                                     promptUser,
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

- (void)setUp {
    // Run before each test method
}

- (void)tearDown {
    // Run after each test method
}  

- (void)testPasswordCreate {
    NSError *error = nil;
    BOOL success = [HAKeychain createPassword:@"testpass"
                                   forService:@"testservice"
                                      account:@"testaccount"
                                     keychain:&testKeychain
                                        error:&error];
    GHAssertTrue(success, @"Password creation failed");    
}

@end