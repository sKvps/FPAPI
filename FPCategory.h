//
//  FPCategory.h
//  Facepunch
//
//  Created by Jerish Brown on 2/7/12.
//  Copyright (c) 2012 i3Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPCategory : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSInteger ID;
@property (nonatomic, strong) NSArray *forums;

@end
