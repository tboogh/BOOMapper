//
//  PiranhaRoot.h
//  BOOJsonMapper
//
//  Created by Tobias Boogh on 01/09/14.
//  Copyright (c) 2014 Tobias Boogh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PiranhaPage.h"
#import "PiranhaContent.h"
#import "PiranhaPost.h"

@interface PiranhaChanges : NSObject
@property (nonatomic, strong) NSArray<PiranhaPage> *Sitemap;
@property (nonatomic, strong) NSArray<PiranhaPage> *Pages;
@property (nonatomic, strong) NSArray<PiranhaContent> *Content;
@property (nonatomic, strong) NSArray<PiranhaPost> *Posts;
@end
