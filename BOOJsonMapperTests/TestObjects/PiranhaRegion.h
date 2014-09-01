//
//  PiranhaRegion.h
//  BOOJsonMapper
//
//  Created by Tobias Boogh on 01/09/14.
//  Copyright (c) 2014 Tobias Boogh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PiranhaRegion <NSObject>

@end

@interface PiranhaRegion : NSObject
@property (nonatomic, copy) NSString *Name;
@property (nonatomic, strong) NSDictionary *Body;
@end
