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

## Requirements

Make sure to include AFNetworking in your project. If you are not using ARC, please apply the following compile flags to each one of the files included:

	-fobjc-arc

## License

FreeBSD License
See LICENSE for more information.