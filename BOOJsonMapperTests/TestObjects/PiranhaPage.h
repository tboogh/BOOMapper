//
//  PiranhaPage.h
//  BOOJsonMapper
//
//  Created by Tobias Boogh on 01/09/14.
//  Copyright (c) 2014 Tobias Boogh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PiranhaRegion.h"

@protocol PiranhaPage <NSObject>
@end

@interface PiranhaPage : NSObject
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *Title;
@property (nonatomic, copy) NSString *Permalink;
@property (nonatomic, copy) NSNumber *Seqno;
@property (nonatomic, copy) NSString *TemplateName;
@property (nonatomic, copy) NSString *NavigationTitle;
@property (nonatomic) BOOL IsHidden;
@property (nonatomic) BOOL HasChildren;
@property (nonatomic, strong) NSDate *LastPublished;
@property (nonatomic, strong) NSDate *Created;
@property (nonatomic, strong) NSDate *Updated;
@property (nonatomic, strong) NSDictionary *Regions;
@property (nonatomic, strong) NSArray<PiranhaPage> *ChildNodes;

@end
