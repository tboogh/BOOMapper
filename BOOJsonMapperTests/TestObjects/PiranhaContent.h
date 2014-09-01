//
//  PiranhaContent.h
//  BOOJsonMapper
//
//  Created by Tobias Boogh on 01/09/14.
//  Copyright (c) 2014 Tobias Boogh. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 "DisplayName" : "RTU bild.png",
 "Filename" : "RTU bild.png",
 "Description" : null,
 "Id" : "69da8fd7-ace0-4e40-a61a-0079e6054b5f",
 "Name" : null,
 "ContentUrl" : "\/media\/69da8fd7-ace0-4e40-a61a-0079e6054b5f",
 "Updated" : "10\/9\/2012 4:59:08 PM",
 "Categories" : [
 
 ],
 "ThumbnailUrl" : "\/thumb\/69da8fd7-ace0-4e40-a61a-0079e6054b5f",
 "Type" : "image\/png",
 "Size" : 211521,
 "ParentId" : "f7d7e789-33f0-4955-aa97-94d0ddd3aba1",
 "Created" : "10\/9\/2012 4:59:08 PM"

 */

@protocol PiranhaContent <NSObject>

@end


@interface PiranhaContent : NSObject
@property (nonatomic, copy) NSString *DisplayName;
@property (nonatomic, copy) NSString *Filename;
@property (nonatomic, copy) NSString *Description;
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *Name;
@property (nonatomic, copy) NSString *ContentUrl;
@property (nonatomic, strong) NSDate *Updated;
@property (nonatomic, strong) NSArray *Categories;
@property (nonatomic, copy) NSString *ThumbnailUrl;
@property (nonatomic, copy) NSString *Type;
@property (nonatomic, copy) NSNumber *Size;
@property (nonatomic, copy) NSNumber *ParentId;
@property (nonatomic, copy) NSDate *Created;

@end
