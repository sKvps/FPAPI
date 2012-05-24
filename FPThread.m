//
//  FPThread.m
//  Facepunch
//
//  Created by Jerish Brown on 2/8/12.
//  Copyright (c) 2012 i3Software. All rights reserved.
//

#import "FPThread.h"

@implementation FPThread
@synthesize ID, title, iconURL, status, locked, pages, usersReading, replyCount, viewCount, author, lastpostid;

-(void)dealloc {
    self.title = nil;
    self.iconURL = nil;
    self.author = nil;
    self.status = nil;
}

@end
