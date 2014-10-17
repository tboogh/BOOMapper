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
@property (nonatomic, strong) NSString *protocolName;
@end

//Blocks
typedef id(^BOOMapperPropertyMapperBlock)(id input);
typedef id(^BOOMapperPropertyMapperResolveClassBlock)(Class inClass, NSString *propertyName);
typedef id(^BOOMapperPropertyMapperClassInstanceBlock)(Class aClass);

@interface BOOMapper : NSObject
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
-(id)objectFromDictionary:(NSDictionary *)dictionary;
-(NSArray *)arrayFromCSVFile:(NSString *)file withClass:(Class)csvClass ignoreHeaderRow:(BOOL)ignoreHeader;
-(void)resolvePropertiesForClassUsingBlock:(BOOMapperPropertyMapperResolveClassBlock)resolveBlock;
-(void)instantiateClassesWithBlock:(BOOMapperPropertyMapperClassInstanceBlock)instanceBlock;
-(void)forClass:(Class)inClass forPropertyNames:(NSString *)property mapUsingBlock:(BOOMapperPropertyMapperBlock)block;

+(NSArray *)propertyAttributesForClass:(Class)class;
@end
