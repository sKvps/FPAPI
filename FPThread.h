//
//  FPThread.h
//  Facepunch
//
//  Created by Jerish Brown on 2/8/12.
//  Copyright (c) 2012 i3Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FPUser;

@interface FPThread : NSObject

@property (nonatomic) NSInteger ID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *iconURL;
@property (nonatomic, strong) NSString *status;
@property (nonatomic) BOOL locked;
@property (nonatomic) NSInteger pages;
@property (nonatomic) NSInteger usersReading;
@property (nonatomic) NSInteger replyCount;
@property (nonatomic) NSInteger viewCount;
@property (nonatomic, strong) FPUser *author;
@property (nonatomic) NSInteger lastpostid;

@end
