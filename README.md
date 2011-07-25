
# HAKeychain #

This isn't ready to be used yet. The rest of this README is a draft.


## Features ##

* Easier API for dealing with the OS X Keychain.
* Works in XCode 4.0.
* Provides easy, localizable error reporting.
* Full test suite.

## Creating a Password ##

For almost every case, saving passwords in the user's default (login) keychain
makes the most sense. (You cannot create a password for the same service and
account twice; if you want to update an already-saved password, use the update
method below instead.) Here's how to create a new password in the default
keychain:

```objective-c
NSError *error = nil;
BOOL success = [HAKeychain createPassword:@"mypassword"
                               forService:@"myservice"
                                  account:@"myaccount"
                                 keychain:NULL
                                    error:&error];
```

## Reading a Password ##

Here's how to find a password you've previously saved:

```objective-c
NSError *error = nil;
NSString *foundPassword = [HAKeychain findPasswordForService:@"myservice"
                                                     account:@"myaccount"
                                                    keychain:NULL
                                                       error:&error];
```

## Deleting a Password ##

To delete an existing password:

```objective-c
NSError *error = nil;
BOOL deleted = [HAKeychain deletePasswordForService:@"myservice"
                                            account:@"myaccount"
                                           keychain:NULL
                                              error:&error];
```

## Reporting Errors ##

HAKeychain supports localized descriptions of Keychain-related errors, so
you can very easily report problems to users. These messages are lightly
modified from the error descriptions provided by Apple (in comments on 
&lt;Security/SecBase.h&gt;).

After any call, if an error is reported (if a BOOL return is `NO` or an object
return is `nil`), you can show a localized error dialog as follows:

```objective-c
if (success == NO && error != nil) {  // or: result == nil && error != nil
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert runModal];
}
```

Hopefully the error message is helpful to the user. If not, you can always
override the message provided.  Localized strings are only provided in English,
though pull requests for other languages are welcome (see
[Localizable.strings](https://github.com/precipice/HAKeychain/blob/master/HAKeychain/en.lproj/Localizable.strings)
if you want to contribute).

## Example Code ##

```objective-c
// Save a new password the user has entered.
NSError *error = nil;
BOOL success = [HAKeychain createPassword:@"mypassword"
                               forService:@"myservice"
                                  account:@"myaccount"
                                 keychain:NULL
                                    error:&error];

if (success == NO && error != nil) {
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert runModal];
} else {
    // ... success ...
}

// ...

// Read in a previously-saved password.
NSError *error = nil;
NSString *foundPassword = [HAKeychain findPasswordForService:@"myservice"
                                                     account:@"myaccount"
                                                    keychain:NULL
                                                       error:&error];
if (foundPassword == nil && error != nil) {
   NSAlert *alert = [NSAlert alertWithError:error];
   [alert runModal];
} else {
   // ... success ...
}
``` 

- Marc Hedlund, <marc@precipice.org>
