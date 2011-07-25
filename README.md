
# HAKeychain #

This isn't ready to be used yet. The rest of this README is a draft.


## Reporting Errors ##

HAKeychain supports localized descriptions of Keychain-related errors, so
you can very easily report problems to users. These messages are lightly
modified from the error descriptions provided by Apple.

After any call, if an error is reported (if a BOOL return is NO or an object
return is nil), you can show a localized error dialog as follows:

    if (success == NO && error != nil) {  // or: result == nil && error != nil
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    }

Hopefully the error message is helpful to the user. If not, you can always
override the message provided.  Localized strings are only provided in English,
though pull requests for other languages are welcome.
