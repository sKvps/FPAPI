//
//  FPAPI.m
//  Facepunch
//
//  Created by Jerish Brown on 2/4/12.
//  Copyright (c) 2012 i3Software. All rights reserved.
//

#import <SBJson/SBJson.h>

#import "FPAPI.h"
#import "FPSession.h"

#import "FPCategory.h"
#import "FPForum.h"
#import "FPThread.h"
#import "FPPost.h"

#import "FPUser.h"

#import "AFNetworking.h"
#import "AFHTTPRequestHelper.h"

@implementation FPAPI
@synthesize requestBaseURL, currentSession, responsesDictionary, facepunchBaseURL;

static FPAPI *sharedInstance; // Static, shared instance. Singleton implementation
+(FPAPI *)sharedInstance {
    @synchronized(self) {
        
        if (sharedInstance == NULL)
            sharedInstance = [[FPAPI alloc] init];
        
    }
    
    return sharedInstance;
}

-(id)init {
    if (sharedInstance != NULL)
        [NSException raise:@"Trying to initilize a second FPAPI instance." format:nil]; // Singleton
    
    self = [super init];
    
    if (self) {
        // Load Base URLs for Content and API requests
        self.requestBaseURL = @"https://api.facepun.ch/?action="; // Base URL for all API requests
        self.facepunchBaseURL = @"http://www.facepunch.com/"; // Base URL for any content needed to be pulled from Facepunch
        
        // Load the file that contains all responses for API calls
        self.responsesDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"responsesDictionary" ofType:@"plist"]]; 
        
        // Initalize the session variable
        self.currentSession = [[FPSession alloc] init];;
    }
    
    return self;
}

-(void)dealloc {
    self.requestBaseURL = nil;
    self.currentSession = nil;
    self.responsesDictionary = nil;
    self.facepunchBaseURL = nil;
}

#pragma mark - Authentication
-(void)authenticateWithUsername:(NSString*)username password:(NSString*)passwordMD5 andCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate {
    // Remove the currentSession credentials (if any)
    self.currentSession.username = @"";
    self.currentSession.password = @"";
    
    username = [username stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    
    // Setup request URL
    NSString *authenticationURL = [NSString stringWithFormat:@"%@authenticate&username=%@&password=%@",
                                                            self.requestBaseURL, username, passwordMD5];
    
    AFHTTPRequestOperation *authenticationRequest = [AFHTTPRequestHelper requestWithUrl:authenticationURL];
    
    [authenticationRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Create a JSON parser to parse the JSON returned by the server
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        
        // Get the payload returned by the server
        NSDictionary *responsePayload = [jsonParser objectWithString:operation.responseString];
        
        // Get all acceptable responses for Login actions
        NSDictionary *loginResponses = [self.responsesDictionary objectForKey:@"Login"];
        
        // Get the key returned on success
        NSString *successKey = [loginResponses valueForKey:@"successKey"];
        
        // Get the name of the error key from the server
        NSString *errorKey = [loginResponses objectForKey:@"errorKey"];
        
        // Get the error returned by the server (if any)
        NSString *loginError = [responsePayload valueForKey:errorKey];
        
        // Make sure no errors occured
        if (loginError == nil) {
            // Double-Check to see if Login was OK
            if ([[responsePayload valueForKey:successKey] isEqualToString: [loginResponses valueForKey:successKey]]) {
                // Setup the new Session
                self.currentSession.username = [[NSString alloc] initWithString:username];
                self.currentSession.password = [[NSString alloc] initWithString:passwordMD5];
                
                // Tell the Delegate that login was good!
                [callbackDelegate facepunchAPIAuthenticationComleted];
            } else {
                // Tell the Delegate that login wasn't good
                [callbackDelegate facepunchAPIAuthenticationFailedWithError:NSLocalizedString(@"APIErrorString", @"")];
            }
        } else {
            // Localize the error returned by the server
            NSString *localizedError = NSLocalizedString(loginError, @"Get Threads Error");
            
            // If the error string isnt localized, set the error to the english version
            if (localizedError == nil) localizedError = loginError;
            
            // Tell the callback delegate that an error occured
            [callbackDelegate facepunchAPIAuthenticationFailedWithError:localizedError];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Something is wrong with the network or API!
        NSString *loginError = [error localizedDescription];
        
        [callbackDelegate facepunchAPIAuthenticationFailedWithError:loginError];
    }];
    
    // Add the Request to a new Operation Queue
    [[[NSOperationQueue alloc] init] addOperation:authenticationRequest];
}

#pragma mark - Get Forums
-(void)getForumsUsingCurrentSessionAndCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate {
    [self getForumsUsingSession:self.currentSession andCallbackDelegate:callbackDelegate];
}

-(void)getForumsUsingSession:(FPSession*)session andCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate {
    NSString *getForumsURL = [NSString stringWithFormat:@"%@getforums&username=%@&password=%@",
                              self.requestBaseURL, session.username, session.password];
    
    AFHTTPRequestOperation *getForumsRequest = [AFHTTPRequestHelper requestWithUrl:getForumsURL];
    
    [getForumsRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Create a JSON parser to parse the JSON returned by the server
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        
        // Get the payload returned by the server
        NSDictionary *responsePayload = [jsonParser objectWithString:operation.responseString];
        
        // Get all acceptable responses for GetForums actions
        NSDictionary *getForumsResponses = [self.responsesDictionary objectForKey:@"GetForums"];
        
        // Get the key returned on success and the key returned on failure
        NSString *successKey = [getForumsResponses valueForKey:@"successKey"];
        NSString *errorKey = [getForumsResponses valueForKey:@"errorKey"];
        
        // Get the categories array returned by the server
        NSArray *categoriesArray = [responsePayload objectForKey:successKey];
        
        // Get the error returned by the server
        NSString *getForumsError = [responsePayload objectForKey:errorKey];
        
        // Check if an error occured
        if (getForumsError == nil) {
            // Double-Check to see if a valid response was returned
            if (categoriesArray != nil) {
                // Create an array to hold the FPCategory objects that will be created from categoriesArray
                NSMutableArray *newCategoriesArray = [[NSMutableArray alloc] init];
                
                // Get the keys that are used for properties of categories
                NSString *successCategoryNameKey = [getForumsResponses valueForKey:@"successCategoryNameKey"];
                NSString *successCategoryIDKey = [getForumsResponses valueForKey:@"successCategoryIDKey"];
                NSString *successCategoryForumsKey = [getForumsResponses valueForKey:@"successCategoryForumsKey"];
                
                // Get the keys that are used for properties of forums
                NSString *successForumNameKey = [getForumsResponses valueForKey:@"successForumNameKey"];
                NSString *successForumIDKey = [getForumsResponses valueForKey:@"successForumIDKey"];
                NSString *successForumViewingKey = [getForumsResponses valueForKey:@"successForumViewingKey"];
                
                // Enumerate through the categoriesArray and create FPCategory objects which then are added into the newCategoriesArray
                for (NSDictionary *category in categoriesArray) {
                    FPCategory *categoryObject = [[FPCategory alloc] init];
                    
                    // Get the forums returned
                    NSArray *forumsArray = [category objectForKey:successCategoryForumsKey];
                    
                    // Create an array to hold the FPForum objects that will be created from the forumsArray
                    NSMutableArray *newForumsArray = [[NSMutableArray alloc] init];
                    
                    // Enumerate through the forumsArray and create FPForum objects which then are added into the newForumsArray
                    for (NSDictionary *forum in forumsArray) {
                        FPForum *forumObejct = [[FPForum alloc] init];
                        forumObejct.name = [forum valueForKey:successForumNameKey];
                        forumObejct.ID = [[forum valueForKey:successForumIDKey] intValue];
                        forumObejct.usersViewing = [[forum valueForKey:successForumViewingKey] intValue];
                        [newForumsArray addObject:forumObejct];
                    }
                    
                    categoryObject.name = [category objectForKey:successCategoryNameKey];
                    categoryObject.ID = [[category objectForKey:successCategoryIDKey] intValue];
                    categoryObject.forums = newForumsArray;
                    
                    [newCategoriesArray addObject:categoryObject];
                }
                
                // Tell the callback delegate that GetForums was completed
                [callbackDelegate facepunchAPIGetForumsCompletedWithForums:newCategoriesArray];
            } else {
                // Tell the callback delegate that GetForums failed
                [callbackDelegate facepunchAPIGetForumsFailedWithError:NSLocalizedString(@"APIErrorString", @"")];
            }
        } else {
            // Localize the error returned by the server
            NSString *localizedError = NSLocalizedString(getForumsError, @"Get Threads Error");
            
            // If the error string isnt localized, set the error to the english version
            if (localizedError == nil) localizedError = getForumsError;
            
            // Tell the callback delegate that an error occured
            [callbackDelegate facepunchAPIGetForumsFailedWithError:localizedError];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Something is wrong with the network or API!
        NSString *getForumsError = [error localizedDescription];
        
        // Tell the callback delegate that GetForums failed
        [callbackDelegate facepunchAPIGetForumsFailedWithError:getForumsError];
    }];
    
    [[[NSOperationQueue alloc] init] addOperation:getForumsRequest];
}

#pragma mark - Get Threads
-(void)getThreadsInForum:(FPForum*)forum onPage:(NSInteger)page usingSession:(FPSession*)session andCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate {
    [self getThreadsWithForumID:forum.ID onPage:page usingSession:session andCallbackDelegate:callbackDelegate];
}

-(void)getThreadsInForum:(FPForum*)forum onPage:(NSInteger)page usingCurrentSessionAndCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate {
    [self getThreadsWithForumID:forum.ID onPage:page usingSession:self.currentSession andCallbackDelegate:callbackDelegate];
}

-(void)getThreadsWithForumID:(NSInteger)forumID onPage:(NSInteger)page usingCurrentSessionAndCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate {
    [self getThreadsWithForumID:forumID onPage:page usingSession:self.currentSession andCallbackDelegate:callbackDelegate];
}

-(void)getThreadsWithForumID:(NSInteger)forumID onPage:(NSInteger)page usingSession:(FPSession*)session andCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate {
    NSString *getThreadsURL = nil;
    if (page > 1) {
        getThreadsURL = [NSString stringWithFormat:@"%@getthreads&username=%@&password=%@&forum_id=%d&page=%d",
                         self.requestBaseURL, session.username, session.password, forumID, page];
    } else {
        getThreadsURL = [NSString stringWithFormat:@"%@getthreads&username=%@&password=%@&forum_id=%d",
                         self.requestBaseURL, session.username, session.password, forumID];
    }
    
    AFHTTPRequestOperation *getThreadsRequest = [AFHTTPRequestHelper requestWithUrl:getThreadsURL];

    [getThreadsRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Create a JSON parser to parse the JSON returned by the server
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        
        // Get the payload returned by the server
        NSDictionary *responsePayload = [jsonParser objectWithString:operation.responseString];
        
        // Get all acceptable responses for GetThreads actions
        NSDictionary *getThreadsResponses = [self.responsesDictionary objectForKey:@"GetThreads"];
        
        // Get the key returned on success and the key returned on failure
        NSString *successKey = [getThreadsResponses valueForKey:@"successKey"];
        NSString *errorKey = [getThreadsResponses valueForKey:@"errorKey"];
        
        // Get the threads array returned by the server
        NSArray *threadsArray = [responsePayload objectForKey:successKey];
        
        // Get the error returned by the server
        NSString *getThreadsError = [responsePayload objectForKey:errorKey];
        
        // Make sure no error occured
        if (getThreadsError == nil) {
            // Double-Check to see if a valid response was returned
            if (threadsArray != nil) {
                // Get the keys that are used for properties of the threads
                NSString *successThreadIDKey = [getThreadsResponses valueForKey:@"successThreadIDKey"];
                NSString *successThreadTitleKey = [getThreadsResponses valueForKey:@"successThreadTitleKey"];
                NSString *successThreadIconURLKey = [getThreadsResponses valueForKey:@"successThreadIconURLKey"];
                NSString *successThreadStatusKey = [getThreadsResponses valueForKey:@"successThreadStatusKey"];
                NSString *successThreadLockedKey = [getThreadsResponses valueForKey:@"successThreadLockedKey"];
                NSString *successThreadPagesKey = [getThreadsResponses valueForKey:@"successThreadPagesKey"];
                NSString *successThreadReadingKey = [getThreadsResponses valueForKey:@"successThreadReadingKey"];
                NSString *successThreadReplyCountKey = [getThreadsResponses valueForKey:@"successThreadReplyCountKey"];
                NSString *successThreadViewCountKey = [getThreadsResponses valueForKey:@"successThreadViewCountKey"];
                NSString *successThreadAuthorNameKey = [getThreadsResponses valueForKey:@"successThreadAuthorNameKey"];
                NSString *successThreadAuthorIDKey = [getThreadsResponses valueForKey:@"successThreadAuthorIDKey"];
                NSString *successThreadLastPostIDKey = [getThreadsResponses valueForKey:@"successThreadLastPostIDKey"];
                
                // Create an array to hold the FPThread objects that will be created from threadsArray
                NSMutableArray *newThreadsArray = [[NSMutableArray alloc] init];
                
                // Enumerate through all the threads and setup FPThread objects that will be added into newThreadsArray
                for (NSDictionary *thread in threadsArray) {
                    FPThread *threadObject = [[FPThread alloc] init];
                    FPUser *threadAuthor = [[FPUser alloc] init];
                    threadAuthor.name = [thread valueForKey:successThreadAuthorNameKey];
                    threadAuthor.ID = [[thread valueForKey:successThreadAuthorIDKey] intValue];
                    threadObject.author = threadAuthor;
                    
                    threadObject.ID = [[thread valueForKey:successThreadIDKey] intValue];
                    threadObject.title = [thread valueForKey:successThreadTitleKey];
                    threadObject.status = [thread valueForKey:successThreadStatusKey];
                    threadObject.locked = [[thread valueForKey:successThreadLockedKey] boolValue];
                    threadObject.pages = [[thread valueForKey:successThreadPagesKey] intValue];
                    threadObject.usersReading = [[thread valueForKey:successThreadReadingKey] intValue];
                    threadObject.replyCount = [[thread valueForKey:successThreadReplyCountKey] intValue];
                    threadObject.viewCount = [[thread valueForKey:successThreadViewCountKey] intValue];
                    threadObject.lastpostid = [[thread valueForKey:successThreadLastPostIDKey] intValue]; 
                    
                    NSString *iconURL = [thread valueForKey:successThreadIconURLKey];
                    threadObject.iconURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", self.facepunchBaseURL, iconURL]];
                    
                    [newThreadsArray addObject:threadObject];
                }
                
                [callbackDelegate facepunchAPIGetThreadsCompletedWithThreads:newThreadsArray];
            } else {
                [callbackDelegate facepunchAPIGetThreadsFailedWithError:NSLocalizedString(@"APIErrorString", @"")];
            }
        } else {
            // Localize the error returned by the server
            NSString *localizedError = NSLocalizedString(getThreadsError, @"Get Threads Error");
            
            // If the error string isnt localized, set the error to the english version
            if (localizedError == nil) localizedError = getThreadsError;
            
            // Tell the callback delegate that an error occured
            [callbackDelegate facepunchAPIGetThreadsFailedWithError:localizedError];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Something is wrong with the network or API!
        NSString *getThreadsError = [error localizedDescription];
        
        // Tell the callback delegate that GetForums failed
        [callbackDelegate facepunchAPIGetThreadsFailedWithError:getThreadsError];
    }];
    
    [[[NSOperationQueue alloc] init] addOperation:getThreadsRequest];
}

#pragma mark - Get Posts
-(void)getPostsInThread:(FPThread*)thread onPage:(NSInteger)page usingCurrentSessionAndCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate {
    [self getPostsWithThreadID:thread.ID onPage:page usingSession:self.currentSession andCallbackDelegate:callbackDelegate];
}

-(void)getPostsInThread:(FPThread*)thread onPage:(NSInteger)page usingSession:(FPSession*)session andCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate {
    [self getPostsWithThreadID:thread.ID onPage:page usingSession:session andCallbackDelegate:callbackDelegate];
}

-(void)getPostsWithThreadID:(NSInteger)threadID onPage:(NSInteger)page usingCurrentSessionAndCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate {
    [self getPostsWithThreadID:threadID onPage:page usingSession:self.currentSession andCallbackDelegate:callbackDelegate];
}

-(void)getPostsWithThreadID:(NSInteger)threadID onPage:(NSInteger)page usingSession:(FPSession*)session andCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate {
    NSString *getPostsURL = nil;
    if (page > 1) {
        getPostsURL = [NSString stringWithFormat:@"%@getposts&username=%@&password=%@&thread_id=%d&page=%d",
                         self.requestBaseURL, session.username, session.password, threadID, page];
    } else {
        getPostsURL = [NSString stringWithFormat:@"%@getposts&username=%@&password=%@&thread_id=%d",
                         self.requestBaseURL, session.username, session.password, threadID];
    }
    
    AFHTTPRequestOperation *getPostsRequest = [AFHTTPRequestHelper requestWithUrl:getPostsURL];
    
    [getPostsRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Create a JSON parser to parse the JSON returned by the server
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        
        // Get the payload returned by the server
        NSDictionary *responsePayload = [jsonParser objectWithString:operation.responseString];
        
        // Get all acceptable responses for GetThreads actions
        NSDictionary *getPostsResponses = [self.responsesDictionary objectForKey:@"GetPosts"];
        
        // Get the key returned on success and the key returned on failure
        NSString *successKey = [getPostsResponses valueForKey:@"successKey"];
        NSString *errorKey = [getPostsResponses valueForKey:@"errorKey"];
        
        // Get the posts array returned by the server
        NSArray *postsArray = [responsePayload valueForKey:successKey];
        
        // Get the error returned by the server
        NSString *getPostsError = [responsePayload objectForKey:errorKey];
        
        // Make sure no error occured
        if (getPostsError == nil) {
            // Double-Check to see if a valid response was returned
            if (postsArray != nil) {
                // Get the keys that are used for properties of individual users
                NSString *successPostUserIDKey = [getPostsResponses valueForKey:@"successPostUserID"];
                NSString *successPostUsernameKey = [getPostsResponses valueForKey:@"successPostUsernameKey"];
                NSString *successPostUserTitleKey = [getPostsResponses valueForKey:@"successPostTimeKey"];
                NSString *successPostUserJoinDateKey = [getPostsResponses valueForKey:@"successPostUserJoinDateKey"];
                NSString *successPostUserPostCountKey = [getPostsResponses valueForKey:@"successPostUserPostCountKey"];
                NSString *successPostUserAvatarKey = [getPostsResponses valueForKey:@"successPostUserAvatarKey"];
                
                // Get the keys that are used for properties of individual posts
                NSString *successPostRatingsKey = [getPostsResponses valueForKey:@"successPostRatingsKey"];
                NSString *successPostTimeKey = [getPostsResponses valueForKey:@"successPostTimeKey"];
                NSString *successPostMessageKey = [getPostsResponses valueForKey:@"successPostMessageKey"];
                NSString *successPostStatusKey = [getPostsResponses valueForKey:@"successPostStatusKey"];
                NSString *successPostRatingKeysKey = [getPostsResponses valueForKey:@"successPostUserPostCountKey"];
                
                // Create an array to hold the FPPost objects that will be created from postsArray
                NSMutableArray *newPostsArray = [[NSMutableArray alloc] init];
                
                // Enumerate through all the threads and setup FPPost objects that will be added into newPostsArray
                for (NSDictionary *post in postsArray) {
                    FPPost *postObject = [[FPPost alloc] init];
                    postObject.message = [post valueForKey:successPostMessageKey];
                    postObject.ratings = [post valueForKey:successPostRatingsKey];
                    postObject.ratingKeys = [post valueForKey:successPostRatingKeysKey];
                    postObject.status = [post valueForKey:successPostStatusKey];
                    postObject.time = [post valueForKey:successPostTimeKey];
                    
                    FPUser *postAuthor = [[FPUser alloc] init];
                    
                    postAuthor.name = [post valueForKey:successPostUsernameKey];
                    postAuthor.ID = [[post valueForKey:successPostUserIDKey] intValue];
                    postAuthor.title = [post valueForKey:successPostUserTitleKey];
                    postAuthor.joinDate = [post valueForKey:successPostUserJoinDateKey];
                    postAuthor.postCount = [[post valueForKey:successPostUserPostCountKey] intValue];
                    
                    NSString *avatarURL = [post valueForKey:successPostUserAvatarKey];
                    postAuthor.avatarURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", self.facepunchBaseURL, avatarURL]];
                    
                    postObject.author = postAuthor;
                    
                    [newPostsArray addObject:postObject];
                }
                
                [callbackDelegate facepunchAPIGetPostsCompletedWithPosts:newPostsArray];
            } else {
                [callbackDelegate facepunchAPIGetPostsFailedWithError:NSLocalizedString(@"APIErrorString", @"")];
            }
        } else {
            // Localize the error returned by the server
            NSString *localizedError = NSLocalizedString(getPostsError, @"Get Threads Error");
            
            // If the error string isnt localized, set the error to the english version
            if (localizedError == nil) localizedError = getPostsError;
            
            // Tell the callback delegate that an error occured
            [callbackDelegate facepunchAPIGetPostsFailedWithError:localizedError];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Something is wrong with the network or API!
        NSString *getPostsError = [error localizedDescription];
        
        // Tell the callback delegate that GetForums failed
        [callbackDelegate facepunchAPIGetPostsFailedWithError:getPostsError];
    }];
    
    [[[NSOperationQueue alloc] init] addOperation:getPostsRequest];
}

@end
