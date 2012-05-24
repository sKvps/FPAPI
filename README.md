# Facepunch Objective-C API

Facepunch API designed for iOS. 

## Usage

	-(void)viewDidLoad {
		[super viewDidLoad];

    	FPAPI *apiInstance = [FPAPI sharedInstance];
    	
    	// Authenticate
    	[apiInstance authenticateWithUsername:@"garry" password:@"d270b849d11910770dc111266ac20a7f" andCallbackDelegate:self];
	}

	-(void)facepunchAPIAuthenticationComleted {

		FPAPI *apiInstance = [FPAPI sharedInstance];

		// Get Forums
		[apiInstance getForumsUsingCurrentSessionAndCallbackDelegate:self];

	}

	-(void)facepunchAPIGetForumsCompletedWithForums:(NSArray*)forums {

		// You now have a NSArray filled with FPForum Objects!

	}

## Adding to the API

There are three main things that make FPAPI work:
- FPAPI.h / FPAPI.m
- responsesDictionary.plist
- FP Model Classes

### FPAPI.h / FPAPI.m

Use these files to implement network requests and add delegate callbacks. If you create a new API Operation, follow the naming convention in place, and make use of the responses dictionary.

### responsesDictionary.plist

This .plist file is used to link API responses with API requests. When adding a API request, choose a common name for the .plist. For example, if you are implementing authenticate, name the key "Login" or "Authenticate"

	<key>Login</key>
	<dict>

Then, within this new dictionary, you must create two keys: successKey and errorKey. Find out what the API responds on success and error and set the key's values respectively.

	<key>successKey</key>
	<string>login</string>
	<key>errorKey</key>
	<string>error</string>

Now you create the values that the API responds with. For example, the value for successKey in a authentication request is "Login OK". Set a key, named however you wish (make the name make sense), to the value of the response you desire.

	<key>login</key>
	<string>Login OK</string>

Here is a example of a completed responsesDictionary.plist entry (GetForums)

	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
		<key>successKey</key>
		<string>categories</string>
		<key>errorKey</key>
		<string>error</string>
		<key>successCategoryNameKey</key>
		<string>name</string>
		<key>successCategoryIDKey</key>
		<string>id</string>
		<key>successCategoryForumsKey</key>
		<string>forums</string>
		<key>successForumNameKey</key>
		<string>name</string>
		<key>successForumIDKey</key>
		<string>id</string>
		<key>successForumViewingKey</key>
		<string>viewing</string>
	</dict>
	</plist>

### FP Model Classes

FP Model Classes are used to contain data returned from the API. Make use of these. FP Model Classes shouldn't have many methods, but only contain properties and ivars that contain data for easy use by your application.

## Requirements

Make sure to include AFNetworking in your project. If you are not using ARC, please apply the following compile flags to each one of the files included:

	-fobjc-arc

## License

FreeBSD License. See LICENSE for more information.