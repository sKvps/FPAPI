//
//  FPUser.m
//  Facepunch
//
//  Created by Jerish Brown on 2/8/12.
//  Copyright (c) 2012 i3Software. All rights reserved.
//

#import "FPUser.h"

@implementation FPUser
@synthesize name, ID, title, joinDate, avatarURL, postCount;

-(void)dealloc {
    self.name = nil;
    self.title = nil;
    self.joinDate = nil;
    self.avatarURL = nil;
}

@end
