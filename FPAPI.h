//
//  FPAPI.h
//  Facepunch
//
//  Created by Jerish Brown on 2/4/12.
//  Copyright (c) 2012 i3Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FPSession;
@class FPForum;
@class FPThread;

@class AFHTTPRequestOperation;

@protocol FPCallbackDelegate;
@interface FPAPI : NSObject

@property (nonatomic, strong) NSString *requestBaseURL;
@property (nonatomic, strong) NSString *facepunchBaseURL;
@property (nonatomic, strong) FPSession *currentSession;
@property (nonatomic, strong) NSDictionary *responsesDictionary;

+(FPAPI *)sharedInstance;

// Authenticate
-(void)authenticateWithUsername:(NSString*)username password:(NSString*)passwordMD5 andCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate;

// Get Forums
-(void)getForumsUsingCurrentSessionAndCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate;
-(void)getForumsUsingSession:(FPSession*)session andCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate;;

// Get Threads
-(void)getThreadsInForum:(FPForum*)forum onPage:(NSInteger)page usingCurrentSessionAndCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate;
-(void)getThreadsInForum:(FPForum*)forum onPage:(NSInteger)page usingSession:(FPSession*)session andCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate;

-(void)getThreadsWithForumID:(NSInteger)forumID onPage:(NSInteger)page usingCurrentSessionAndCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate;
-(void)getThreadsWithForumID:(NSInteger)forumID onPage:(NSInteger)page usingSession:(FPSession*)session andCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate;

// Get Posts
-(void)getPostsInThread:(FPThread*)thread onPage:(NSInteger)page usingCurrentSessionAndCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate;
-(void)getPostsInThread:(FPThread*)thread onPage:(NSInteger)page usingSession:(FPSession*)session andCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate;

-(void)getPostsWithThreadID:(NSInteger)threadID onPage:(NSInteger)page usingCurrentSessionAndCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate;
-(void)getPostsWithThreadID:(NSInteger)threadID onPage:(NSInteger)page usingSession:(FPSession*)session andCallbackDelegate:(id<FPCallbackDelegate>)callbackDelegate;

@end

@protocol FPCallbackDelegate
@optional

-(void)facepunchAPIAuthenticationComleted;
-(void)facepunchAPIAuthenticationFailedWithError:(NSString*)error;

// NSArray *forums is an NSArray containing FPForum objects.
-(void)facepunchAPIGetForumsCompletedWithForums:(NSArray*)forums;
-(void)facepunchAPIGetForumsFailedWithError:(NSString*)error;

// NSArray *threads is an NSArray containing FPThread objects.
-(void)facepunchAPIGetThreadsCompletedWithThreads:(NSArray*)threads;
-(void)facepunchAPIGetThreadsFailedWithError:(NSString*)error;

// NSArray *posts is an NSArray containing FPPost objects
-(void)facepunchAPIGetPostsCompletedWithPosts:(NSArray*)posts;
-(void)facepunchAPIGetPostsFailedWithError:(NSString*)error;

@end