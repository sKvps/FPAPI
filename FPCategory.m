//
//  FPCategory.m
//  Facepunch
//
//  Created by Jerish Brown on 2/7/12.
//  Copyright (c) 2012 i3Software. All rights reserved.
//

#import "FPCategory.h"

@implementation FPCategory
@synthesize name, ID, forums;

-(void)dealloc {
    self.name = nil;
    self.forums = nil;
}

@end
