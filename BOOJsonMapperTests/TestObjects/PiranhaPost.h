//
//  PiranhaPosts.h
//  BOOJsonMapper
//
//  Created by Tobias Boogh on 01/09/14.
//  Copyright (c) 2014 Tobias Boogh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PiranhaPost <NSObject>
@end

/*
 LastPublished" : "5\/7\/2013 10:59:00 AM",
 "Id" : "b30e71a3-3414-448c-a57c-01d3e86f82dc",
 "TemplateName" : "Product",
 "Excerpt" : null,
 "Body"
 "Extensions" : [
 "Categories" : [
 
 ],
 "Updated" : "5\/7\/2013 10:59:00 AM",
 "ExpandedExtensions" : {
 
 "Title" : "Oljeisolerade Transformatorer",
 "Properties" : [
 
 ],
 "Permalink" : "oljeisolerade-transformatorer",
 "Attachments" : [
 "Created" : "10\/9\/2012 4:59:08 PM",
 "Published" : "10\/9\/2012 4:59:08 PM"
 */

@interface PiranhaPost : NSObject
@property (nonatomic, strong) NSDate *LastPublished;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *TemplateName;
@property (nonatomic, strong) NSString *Excerpt;
@property (nonatomic, strong) NSString *Body;
@property (nonatomic, strong) NSArray *Extensions;
@property (nonatomic, strong) NSArray *Categories;
@property (nonatomic, strong) NSDate *Updated;
@property (nonatomic, strong) NSDictionary *ExpandedExtensions;
@property (nonatomic, strong) NSString *Title;
@property (nonatomic, strong) NSArray *Properties;
@property (nonatomic, strong) NSString *Permalink;
@property (nonatomic, strong) NSArray *Attachments;
@property (nonatomic, strong) NSDate *Created;
@property (nonatomic, strong) NSDate *Published;
@end
