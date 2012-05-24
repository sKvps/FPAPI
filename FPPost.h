//
//  FPPost.h
//  Facepunch
//
//  Created by Jerish Brown on 2/14/12.
//  Copyright (c) 2012 i3Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FPUser;

@interface FPPost : NSObject

@property (nonatomic, strong) FPUser *author;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *time;

@property (nonatomic, strong) NSDictionary *ratings;
@property (nonatomic, strong) NSDictionary *ratingKeys;

@end
