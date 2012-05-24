//
//  FPUser.h
//  Facepunch
//
//  Created by Jerish Brown on 2/8/12.
//  Copyright (c) 2012 i3Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPUser : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSInteger ID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *joinDate;
@property (nonatomic) NSInteger postCount;
@property (nonatomic, strong) NSURL *avatarURL;

@end
