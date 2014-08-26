//
//  BOOJsonMapper.h
//  BOOJsonMapper
//
//  Created by Tobias Boogh on 26/08/14.
//  Copyright (c) 2014 Tobias Boogh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BOOMapper;

@interface BOOMapperPropertyInfo : NSObject
@property (nonatomic) BOOL isReadonly;
@property (nonatomic) BOOL isCopy;
@property (nonatomic) BOOL isRetain;
@property (nonatomic) BOOL isNonAtomic;
@property (nonatomic) BOOL hasCustomGetter;
@property (nonatomic) BOOL hasCustomSetter;
@property (nonatomic) BOOL isDynamic;
@property (nonatomic) BOOL isWeak;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *customGetterName;
@property (nonatomic, strong) NSString *customSetterName;
@property (nonatomic, strong) NSString *className;
@end

@protocol BOOMapperDelegate <NSObject>
@optional
-(Class)mapper:(BOOMapper *)mapper classForPropertyWithName:(NSString *)propertyName parentClass:(Class)parentClass;
-(id)mapper:(BOOMapper *)mapper instanceForClass:(Class)class;
@end

@interface BOOMapper : NSObject
@property (nonatomic, weak) id<BOOMapperDelegate> delegate;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
-(instancetype)initWithDelegate:(id<BOOMapperDelegate>)delegate;
-(id)objectFromDictionary:(NSDictionary *)dictionary;-(id)objectFromDictionary:(NSDictionary *)dictionary class:(Class)class;
@end
