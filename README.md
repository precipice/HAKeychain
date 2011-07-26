
# HAKeychain #

I went looking for a simpler way to use 
[Keychain](http://en.wikipedia.org/wiki/Keychain_(Mac_OS)) in Mac OS X app
development, and couldn't find an open source library that worked in XCode 4.
Several of the projects I found looked unmaintained or untested, and all of 
them made reporting errors a big pain (as does Keychain itself). HAKeychain
is my stab at providing the library I'd hoped to find solving these 
problems.

(**Note:** this library does not support iOS Keychain, at least not yet. Check out
[scifihifi-iphone](https://github.com/ldandersen/scifihifi-iphone/tree/master/security)
for that.)

## Features ##

* Simpler API for dealing with the OS X Keychain.
* Works in XCode 4.0.
* Provides easy, localizable error reporting.
* Full test suite.

## Quick Start ##

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

## Installing the Framework ##

To use HAKeychain in an XCode 4 project, use the following steps (modified
from the [gh-unit install steps](http://gabriel.github.com/gh-unit/_installing_xcode3.html)).

1. Download HAKeychain.framework.zip from 
   [Downloads](https://github.com/precipice/HAKeychain/downloads) and unzip it.
2. Open your XCode project. Right-click the "Frameworks" folder and select
   "Add File to *project*..."  Select the unzipped framework folder and check
   the "Copy items into destination group's folder (if needed)" checkbox.
3. In your app target, in Build Settings, add `@loader_path/../Frameworks` to
   `Runpath Search Paths`.
4. In your app target, in Build Phases, select `Add Build Phase` and then 
   `Add Copy Files`:
    * Change the Destination to `Frameworks`.
    * Drag `HAKeychain.framework` from the project file view into the the 
      `Copy Files` build phase.
    * Make sure the copy phase appears before any `Run Script` phases.

For XCode 3, try out [these steps](http://gabriel.github.com/gh-unit/_installing_xcode3.html#InstallMacOSXXcode3) 
instead. 

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

## Updating a Password ##

Updating a password just runs delete and then create for you as a convenience.
Here's how:

```objective-c
NSError *error = nil;
BOOL updated = [HAKeychain updatePassword:@"mynewpassword"
                               forService:@"myservice"
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

## Displaying Errors ##

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

If you'd rather not show the error to the user, or would like to display it
in another form, you can just extract the localized message:

```objective-c
if (success == NO && error != nil) {  // or: result == nil && error != nil
    NSLog(@"Keychain error: %@", [error localizedDescription]);
}
```

Hopefully the error message is helpful to the user. If not, you can always
override the message provided.  Localized strings are only provided in English,
though pull requests for other languages are welcome (see
[Localizable.strings](https://github.com/precipice/HAKeychain/blob/master/HAKeychain/en.lproj/Localizable.strings)
if you want to contribute).

## Implementation Note ##

HAKeychain stores all passwords as Generic security items for simplicity.
It looks like that storage format may be going away; in which case a future
version of the library may store items as Internet passwords under the covers.
If anyone knows the Right path on this I'd be interested to hear about it.

## Credits ##

Thanks to the following projects for inspiration and ideas:

* [sskeychain](https://github.com/samsoffes/sskeychain)
* [objectiveyoutube](http://code.google.com/p/objectiveyoutube)

Thanks also to [ldandersen](https://github.com/ldandersen) for his 
[iOS Keychain work](https://github.com/ldandersen/scifihifi-iphone/tree/master/security).

## Contributions ##

Pull requests welcome. There is a `Tests` target; please make sure your
commits include tests and that the full suite passes before sending a pull.
Thanks!

- Marc Hedlund, <marc@precipice.org>
