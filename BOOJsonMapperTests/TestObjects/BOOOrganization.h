//
//  BOOOrganization.h
//  BOOJsonMapper
//
//  Created by Tobias Boogh on 26/08/14.
//  Copyright (c) 2014 Tobias Boogh. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 "name": "Gutkowski, Mertz and Dooley",
 "channels": []
 */
@interface BOOOrganization : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *channels;
@end
