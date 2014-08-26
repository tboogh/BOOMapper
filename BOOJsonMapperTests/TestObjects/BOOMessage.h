//
//  BOOMessage.h
//  BOOJsonMapper
//
//  Created by Tobias Boogh on 26/08/14.
//  Copyright (c) 2014 Tobias Boogh. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 
 "userId": number
 "message": string
 "postTime": date
 */

@interface BOOMessage : NSObject
@property (nonatomic, copy) NSNumber *userId;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSDate *postTime;
@end
