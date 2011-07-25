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

    OSStatus status = SecKeychainAddGenericPassword(keychain,
                                                    (UInt32)strlen(serviceUTF8),
                                                    serviceUTF8,
                                                    (UInt32)strlen(accountUTF8),
                                                    accountUTF8,
                                                    (UInt32)strlen(passwordUTF8),
                                                    passwordUTF8,
                                                    NULL);
    
    if (status != noErr) [HAKeychain setCode:status error:error];
    return status == noErr;
}


+ (NSString *)findPasswordForService:(NSString *)service
                             account:(NSString *)account
                            keychain:(SecKeychainRef)keychain
                               error:(NSError **)error {
    
    if (![HAKeychain validService:service account:account]) {
        [HAKeychain setCode:errSecParam error:error];
        return nil;
    }
    
    const char *serviceUTF8  = [service UTF8String];
    const char *accountUTF8  = [account UTF8String];
    char *passwordData;
    UInt32 passwordLength;

    OSStatus status = SecKeychainFindGenericPassword(keychain,
                                                     (UInt32)strlen(serviceUTF8),
                                                     serviceUTF8,
                                                     (UInt32)strlen(accountUTF8),
                                                     accountUTF8,
                                                     &passwordLength,
                                                     (void **)&passwordData,
                                                     NULL);

    if (status != noErr) {
        [HAKeychain setCode:status error:error];
        return nil;
        
    } else {
        return [[[NSString alloc] initWithBytesNoCopy:passwordData 
                                               length:passwordLength 
                                             encoding:NSUTF8StringEncoding 
                                         freeWhenDone:YES] 
                autorelease];
    }
}


+ (BOOL)validService:(NSString *)service account:(NSString *)account {
    if (service == NULL || [service length] == 0 ||
        account == NULL || [account length] == 0) {
        return NO;
    }
    return YES;
}


+ (void)setCode:(NSInteger)code error:(NSError **)error {
    if (error != NULL) {
        NSString *description = nil;
        
        switch (code) {
            case errSecSuccess:
                description = NSLocalizedString(@"No error.", @"");
                break;
            case errSecUnimplemented:
                description = NSLocalizedString(@"Keychain function or operation not implemented.", @"");
                break;
            case errSecParam:
                description = NSLocalizedString(@"The password, account, or service name was invalid.", @"");
                break;
            case errSecAllocate:
                description = NSLocalizedString(@"Failed to allocate memory.", @"");
                break;
            case errSecNotAvailable:
                description = NSLocalizedString(@"No keychain is available. You may need to restart your computer.", @"");
                break;
            case errSecReadOnly:
                description = NSLocalizedString(@"The keychain cannot be modified.", @"");
                break;
            case errSecAuthFailed:
                description = NSLocalizedString(@"The keychain username or password you entered is not correct.", @"");
                break;
            case errSecNoSuchKeychain:
                description = NSLocalizedString(@"The keychain could not be found.", @"");
                break;
            case errSecInvalidKeychain:
                description = NSLocalizedString(@"The keychain is not a valid keychain file.", @"");
                break;
            case errSecDuplicateKeychain:
                description = NSLocalizedString(@"A keychain with the same name already exists.", @"");
                break;
            case errSecDuplicateCallback:
                description = NSLocalizedString(@"The keychain callback function is already installed.", @"");
                break;
            case errSecInvalidCallback:
                description = NSLocalizedString(@"The keychain callback function is not valid.", @"");
                break;
            case errSecDuplicateItem:
                description = NSLocalizedString(@"That password already exists in the keychain.", @"");
                break;
            case errSecItemNotFound:
                description = NSLocalizedString(@"The item could not be found in the keychain.", @"");
                break;
            case errSecBufferTooSmall:
                description = NSLocalizedString(@"There is not enough memory available to use the keychain item.", @"");
                break;
            case errSecDataTooLarge:
                description = NSLocalizedString(@"This keychain item contains information which is too large or in a format that cannot be displayed.", @"");
                break;
            case errSecNoSuchAttr:
                description = NSLocalizedString(@"The keychain attribute does not exist.", @"");
                break;
            case errSecInvalidItemRef:
                description = NSLocalizedString(@"The keychain item is no longer valid. It may have been deleted from the keychain.", @"");
                break;
            case errSecInvalidSearchRef:
                description = NSLocalizedString(@"Unable to search the current keychain.", @"");
                break;
            case errSecNoSuchClass:
                description = NSLocalizedString(@"The item does not appear to be a valid keychain item.", @"");
                break;
            case errSecNoDefaultKeychain:
                description = NSLocalizedString(@"A default keychain could not be found.", @"");
                break;
            case errSecInteractionNotAllowed:
                description = NSLocalizedString(@"User interaction is not allowed with that keychain.", @"");
                break;
            case errSecReadOnlyAttr:
                description = NSLocalizedString(@"The keychain attribute could not be modified.", @"");
                break;
            case errSecWrongSecVersion:
                description = NSLocalizedString(@"This keychain was created by a different version of the system software and cannot be opened.", @"");
                break;
            case errSecKeySizeNotAllowed:
                description = NSLocalizedString(@"This item specifies a key size which is too large.", @"");
                break;
            case errSecNoStorageModule:
                description = NSLocalizedString(@"A required component (data storage module) could not be loaded. You may need to restart your computer.", @"");
                break;
            case errSecNoCertificateModule:
                description = NSLocalizedString(@"A required component (certificate module) could not be loaded. You may need to restart your computer.", @"");
                break;
            case errSecNoPolicyModule:
                description = NSLocalizedString(@"A required component (policy module) could not be loaded. You may need to restart your computer.", @"");
                break;
            case errSecInteractionRequired:
                description = NSLocalizedString(@"User interaction is required for that keychain, but is currently not allowed.", @"");
                break;
            case errSecDataNotAvailable:
                description = NSLocalizedString(@"The contents of this keychain item cannot be retrieved.", @"");
                break;
            case errSecDataNotModifiable:
                description = NSLocalizedString(@"The contents of this keychain item cannot be modified.", @"");
                break;
            case errSecCreateChainFailed:
                description = NSLocalizedString(@"One or more certificates required to validate this certificate cannot be found.", @"");
                break;
            case errSecInvalidPrefsDomain:
                description = NSLocalizedString(@"The keychain preferences domain is not valid.", @"");
                break;
            case errSecACLNotSimple:
                description = NSLocalizedString(@"The keychain access control list is not in standard (simple) form.", @"");
                break;
            case errSecPolicyNotFound:
                description = NSLocalizedString(@"The keychain policy cannot be found.", @"");
                break;
            case errSecInvalidTrustSetting:
                description = NSLocalizedString(@"The keychain trust setting is invalid.", @"");
                break;
            case errSecNoAccessForItem:
                description = NSLocalizedString(@"The keychain item has no access control.", @"");
                break;
            case errSecInvalidOwnerEdit:
                description = NSLocalizedString(@"Invalid attempt to change the owner of this keychain item.", @"");
                break;
            case errSecTrustNotAvailable:
                description = NSLocalizedString(@"No keychain trust results are available.", @"");
                break;
            case errSecUnsupportedFormat:
                description = NSLocalizedString(@"Import/Export keychain format unsupported.", @"");
                break;
            case errSecUnknownFormat:
                description = NSLocalizedString(@"Unknown format in keychain import.", @"");
                break;
            case errSecKeyIsSensitive:
                description = NSLocalizedString(@"Keychain material must be wrapped for export.", @"");
                break;
            case errSecMultiplePrivKeys:
                description = NSLocalizedString(@"An attempt was made to import multiple private keys.", @"");
                break;
            case errSecPassphraseRequired:
                description = NSLocalizedString(@"Passphrase is required for keychain import/export.", @"");
                break;
            case errSecInvalidPasswordRef:
                description = NSLocalizedString(@"The keychain password reference was invalid.", @"");
                break;
            case errSecInvalidTrustSettings:
                description = NSLocalizedString(@"The keychain Trust Settings Record was corrupted.", @"");
                break;
            case errSecNoTrustSettings:
                description = NSLocalizedString(@"No keychain Trust Settings were found.", @"");
                break;
            case errSecPkcs12VerifyFailure:
                description = NSLocalizedString(@"MAC verification failed during PKCS12 Import.", @"");
                break;
            case errSecDecode:
                description = NSLocalizedString(@"Unable to decode the provided keychain data.", @"");
                break;
            default:
                description = @"General keychain error.";
                break;
        }
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  description, NSLocalizedDescriptionKey, nil];
        
        *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                     code:code
                                 userInfo:userInfo];
    }    
}

@end
