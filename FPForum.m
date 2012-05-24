//
//  FPForum.m
//  Facepunch
//
//  Created by Jerish Brown on 2/7/12.
//  Copyright (c) 2012 i3Software. All rights reserved.
//

#import "FPForum.h"

@implementation FPForum
@synthesize name, ID, usersViewing;

-(void)dealloc {
    self.name = nil;
}

@end
