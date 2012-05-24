//
//  FPSession.m
//  Facepunch
//
//  Created by Jerish Brown on 2/5/12.
//  Copyright (c) 2012 i3Software. All rights reserved.
//

#import "FPSession.h"

@implementation FPSession
@synthesize username, password;

-(void)dealloc {
    self.username = nil;
    self.password = nil;
}

@end
