//
//  BOOUser.h
//  BOOJsonMapper
//
//  Created by Tobias Boogh on 26/08/14.
//  Copyright (c) 2014 Tobias Boogh. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 "firstName": "Cynthia",
 "lastName": "Hilpert",
 "avatar": "https://s3.amazonaws.com/uifaces/faces/twitter/cynthiasavard/128.jpg",
 "userId": 5993,
 "status": 0
 */

@interface BOOUser : NSObject
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSNumber *userId;
@property (nonatomic, copy) NSNumber *status;
@end
