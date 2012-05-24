//
//  FPPost.m
//  Facepunch
//
//  Created by Jerish Brown on 2/14/12.
//  Copyright (c) 2012 i3Software. All rights reserved.
//

#import "FPPost.h"

@implementation FPPost
@synthesize author, status, message, ratings, ratingKeys, time;

-(void)dealloc {
    self.author = nil;
    self.status = nil;
    self.message = nil;
    self.ratings = nil;
    self.ratingKeys = nil;
    self.time = nil;
}

@end
