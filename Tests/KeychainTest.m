//
//  KeychainTest.m
//  HAKeychain
//
//  Created by Marc Hedlund on 7/22/11.
//  Copyright 2011 Hack Arts, LLC. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import <Security/Security.h>

@interface KeychainTest : GHTestCase { 
    SecKeychainRef testKeychain;
}
@end

@implementation KeychainTest

- (void)setUpClass {
    // Create a test keychain so we can add and delete passwords with glee.
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
    // Clean up the test keychain.
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

- (void)testFoo {       
    NSString *a = @"foo";
    GHTestLog(@"I can log to the GHUnit test console: %@", a);
    
    // Assert a is not NULL, with no custom error description
    GHAssertNotNULL(a, nil);
    
    // Assert equal objects, add custom error description
    NSString *b = @"bar";
    GHAssertEqualObjects(a, b, @"A custom error message. a should be equal to: %@.", b);
}

- (void)testBar {
    // Another test
}

@end