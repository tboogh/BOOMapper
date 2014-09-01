//
//  BOOJsonMapper.m
//  BOOJsonMapper
//
//  Created by Tobias Boogh on 26/08/14.
//  Copyright (c) 2014 Tobias Boogh. All rights reserved.
//

#import "BOOJsonMapper.h"
#import <objc/runtime.h>

@implementation BOOMapperPropertyInfo
-(NSString *)description{
    return [NSString stringWithFormat:@"%@ %@", self.name, self.className];
}
@end

@interface BOOMapper()
@property (nonatomic, strong) NSMutableDictionary *propertyMapperBlocks;
@property (nonatomic, copy) BOOMapperPropertyMapperResolveClassBlock resolveBlock;
@end

@implementation BOOMapper

-(NSDateFormatter *)dateFormatter{
    if (_dateFormatter == nil){
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

-(instancetype)initWithDelegate:(id<BOOMapperDelegate>)delegate{
    self = [super init];
    if (self){
        _delegate = delegate;
        self.propertyMapperBlocks = [[NSMutableDictionary alloc] init];
    }
    return self;
}
-(id)objectFromDictionary:(NSDictionary *)dictionary{
    return [self objectFromDictionary:dictionary class:nil];
}

-(id)objectFromDictionary:(NSDictionary *)dictionary class:(Class)class{
    if (class == nil){
        if ([self.delegate respondsToSelector:@selector(mapper:classForPropertyWithName:parentClass:)]){
            class = [self.delegate mapper:self classForPropertyWithName:nil parentClass:nil];
        } else if (self.resolveBlock != nil){
            class = self.resolveBlock(nil, nil);
        }
    }
    
    if (class == nil){
        NSLog(@"Need class to parse");
        return nil;
    }
    
    NSMutableArray *propertyKeys = [[BOOMapper propertyNamesForClass:class] mutableCopy];
    NSMutableArray *dictionaryKeys = [[dictionary allKeys] mutableCopy];
    
    // Need to fix names in keys to match 
//    [propertyKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        [propertyKeys replaceObjectAtIndex:idx withObject:[obj lowercaseString]];
//    }];
//    [dictionaryKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        [dictionaryKeys replaceObjectAtIndex:idx withObject:[obj lowercaseString]];
//    }];
//    
    NSMutableSet *keys = [NSMutableSet setWithArray:dictionaryKeys];
    NSSet *mappableProperties = [NSSet setWithArray:propertyKeys];
    [keys intersectSet:mappableProperties];
    id object;
    if (self.delegate != nil){
        if ([self.delegate respondsToSelector:@selector(mapper:instanceForClass:)]){
            object = [self.delegate mapper:self instanceForClass:class];
        }
    }
    if (object == nil){
        object = [[class alloc] init];
    }
    
    NSDictionary *propertyInfoDictionary = [BOOMapper propertyAttributesForClass:class];
    
    for (NSString *key in keys) {
        BOOMapperPropertyInfo *info = propertyInfoDictionary[key];
        if (info != nil){
            // The case in the objects key can make it tricky for valueForKey to fetch the value
            // Try to search for it if valueForKey fails
            id dictValue = [dictionary valueForKey:key];
            if (dictValue == nil){
                NSLog(@"Could not find a value for key %@ in object of class %@", key, class);
                continue;
            }
            NSDictionary *propertyMapperBlockDict = self.propertyMapperBlocks[NSStringFromClass(class)];
            id value = nil;
            if (propertyMapperBlockDict != nil){
                BOOMapperPropertyMapperBlock block = propertyMapperBlockDict[info.name];
                if (block != nil) {
                    value = block(dictValue);
                }
            }
            
            if (value == nil){
                value = [self convertedValue:dictValue forProperty:info parentClass:class];
            }
            
            if (info.isReadonly){
                NSLog(@"Cannot set value for %@ as it is readonly", info.name);
            } else if (info.hasCustomSetter){
                SEL selector = NSSelectorFromString(info.customSetterName);
                if ([object respondsToSelector:selector]){
                    IMP imp = [object methodForSelector:selector];
                    void (*func)(id , SEL, id) = (void *)imp;
                    func(object, selector, value);
                }
            } else if (info.isWeak){
                NSLog(@"Warning: Property %@ is a weak reference", info.name);
            } else {
                [object setValue:value forKey:info.name];
            }
        }
    }
    
    return object;
}

-(id)convertedValue:(id)value forProperty:(BOOMapperPropertyInfo *)propertyInfo parentClass:(Class)parentClass{
    if ([value isKindOfClass:[NSDictionary class]]){
        Class class = nil;
        if (self.delegate != nil){
            if ([self.delegate respondsToSelector:@selector(mapper:classForPropertyWithName:parentClass:)]){
                class = [self.delegate mapper:self classForPropertyWithName:propertyInfo.name parentClass:parentClass];
            }
        }
        if (self.resolveBlock != nil && class == nil){
            class = self.resolveBlock(parentClass, propertyInfo.name);
        }
        if (class == nil){
            if (![propertyInfo.protocolName isEqualToString:@""] && propertyInfo.protocolName != nil){
                class = NSClassFromString(propertyInfo.protocolName);
            }
        }
        if (class == nil){
            NSLog(@"No class returned for %@, returning dictionary value", propertyInfo.name);
            return value;
        }
        id object = [self objectFromDictionary:value class:class];
        return object;
    } else {
        Class propertyClass = NSClassFromString(propertyInfo.className);
        if (propertyClass == [NSNumber class]){
            if ([value isKindOfClass:[NSString class]]){
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                return value;
            } else if ([value isKindOfClass:[NSNumber class]]){
                return value;
            } else {
                NSLog(@"Unsupported value class %@ for %@", NSStringFromClass([value class]), NSStringFromClass(propertyClass));
            }
        } else if (propertyClass == [NSString class]){
            if ([value isKindOfClass:[NSString class]]){
                return value;
            } else if ([value isKindOfClass:[NSNumber class]]){
                return [value stringValue];
            } else if ([value isKindOfClass:[NSNull class]]){
                return nil;
            } else {
                NSLog(@"Unsupported value class %@ for %@", NSStringFromClass([value class]), NSStringFromClass(propertyClass));
            }
        } else if (propertyClass == [NSSet class] || propertyClass == [NSMutableSet class]){
            NSMutableSet *set = [[NSMutableSet alloc] init];
            if ([value isKindOfClass:[NSArray class]]){
                for (id arrayValue in value) {
                    id convertedArrayValue = value;
                    if ([arrayValue isKindOfClass:[NSDictionary class]]){
                        if (self.delegate != nil){
                            if ([self.delegate respondsToSelector:@selector(mapper:classForPropertyWithName:parentClass:)]){
                                convertedArrayValue = [self convertedValue:arrayValue forProperty:propertyInfo parentClass:parentClass];
                            }
                        }
                    }
                    if (convertedArrayValue != nil){
                        [set addObject:convertedArrayValue];
                    }
                }
            }
            return set;
        } else if (propertyClass == [NSOrderedSet class] || propertyClass == [NSMutableOrderedSet class]){
            NSMutableOrderedSet *set = [[NSMutableOrderedSet alloc] init];
            if ([value isKindOfClass:[NSArray class]]){
                for (id arrayValue in value) {
                    id convertedArrayValue = value;
                    if ([arrayValue isKindOfClass:[NSDictionary class]]){
                        if (self.delegate != nil){
                            if ([self.delegate respondsToSelector:@selector(mapper:classForPropertyWithName:parentClass:)]){
                                convertedArrayValue = [self convertedValue:arrayValue forProperty:propertyInfo parentClass:parentClass];
                            }
                        }
                    }
                    if (convertedArrayValue != nil){
                        [set addObject:convertedArrayValue];
                    }
                }
            }
            return set;
        } else if (propertyClass == [NSArray class] || propertyClass == [NSMutableArray class]){
            NSMutableArray *array = [[NSMutableArray alloc] init];
            if ([value isKindOfClass:[NSArray class]]){
                for (id arrayValue in value) {
                    id convertedArrayValue = arrayValue;
                    if ([arrayValue isKindOfClass:[NSDictionary class]]){
                        convertedArrayValue = [self convertedValue:arrayValue forProperty:propertyInfo parentClass:parentClass];
                    }
                    if (convertedArrayValue != nil){
                        [array addObject:convertedArrayValue];
                    }
                }
            }
            return array;
        } else if (propertyClass == [NSDate class]){
            if ([value isKindOfClass:[NSDate class]]){
                return value;
            } else if ([value isKindOfClass:[NSString class]]){
                NSDate *date = [self.dateFormatter dateFromString:value];
                return date;
            }
        }
    }
    return value;
}

+(NSArray *)propertyNamesForClass:(Class)class{
    NSMutableArray *propertyArray = [[NSMutableArray alloc] init];
    unsigned int count;
    objc_property_t *list = nil;
    list = class_copyPropertyList(class, &count);
    for (int i=0; i < count; ++i){
        objc_property_t prop = list[i];
        const char *name = property_getName(prop);
        NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        [propertyArray addObject:propertyName];
    }
    return propertyArray;
}

+(NSMutableDictionary *)propertyAttributesForClass:(Class)class{
    NSMutableDictionary *propertyInfoDictionary = [[NSMutableDictionary alloc] init];
    unsigned int count;
    objc_property_t *list = nil;
    list = class_copyPropertyList(class, &count);
    for (int i=0; i < count; ++i){
        objc_property_t prop = list[i];
        const char *name = property_getName(prop);
        
        NSString *attributes = [NSString stringWithCString:property_getAttributes(prop) encoding:NSUTF8StringEncoding];
        
        BOOMapperPropertyInfo *info = [[BOOMapperPropertyInfo alloc] init];
        info.name = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        [propertyInfoDictionary setValue:info forKey:info.name];
        
        NSArray *array = [attributes componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        for (NSString *string in array) {
            unichar firstCharacter = [string characterAtIndex:0];
            if (firstCharacter == 'T'){
                NSString *classString = [[string stringByReplacingOccurrencesOfString:@"T@" withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                
                if ([classString rangeOfString:@"<"].location != NSNotFound){
                    NSString *protocolName = @"";
                    NSScanner *scanner = [NSScanner scannerWithString:classString];
                    [scanner setCharactersToBeSkipped:nil];
                    [scanner scanUpToString:@"<" intoString:&classString];
                    if ([scanner scanString:@"<" intoString:nil]){
                        [scanner scanUpToString:@">" intoString:&protocolName];
                        info.protocolName = protocolName;
                    }
                }
                info.className = classString;
            } else if (firstCharacter == '&'){
                info.isRetain = YES;
            } else if (firstCharacter == 'N'){
                info.isNonAtomic = YES;
            } else if (firstCharacter == 'G'){
                info.hasCustomGetter = YES;
                info.customGetterName = [string substringFromIndex:1];
            } else if (firstCharacter == 'S'){
                info.hasCustomSetter = YES;
                info.customSetterName = [string substringFromIndex:1];
            } else if (firstCharacter == 'V'){
                //              Name already set
                //                NSString *name = [string stringByReplacingOccurrencesOfString:@"V_" withString:@""];
                //                info.name = name;
            } else if (firstCharacter == 'R'){
                info.isReadonly = YES;
            } else if (firstCharacter == 'C'){
                info.isCopy = YES;
            } else if (firstCharacter == 'D'){
                info.isDynamic = YES;
            } else if (firstCharacter == 'W'){
                info.isWeak = YES;
            } else if (firstCharacter == 'P'){
                //              Garbage Collection
            } else {
                NSLog(@"Unknown: %@", string);
            }
        }
    }
    return propertyInfoDictionary;
}

-(void)forClass:(Class)inClass forPropertyNames:(NSString *)property mapUsingBlock:(BOOMapperPropertyMapperBlock)block{
    NSString *className = NSStringFromClass(inClass);
    NSMutableDictionary *propertyDictInClass = self.propertyMapperBlocks[className];
    if (propertyDictInClass == nil){
        propertyDictInClass = [[NSMutableDictionary alloc] init];
        self.propertyMapperBlocks[className] = propertyDictInClass;
    }
    propertyDictInClass[property] = block;
}

-(void)resolvePropertiesForClassUsingBlock:(BOOMapperPropertyMapperResolveClassBlock)resolveBlock{
    self.resolveBlock = resolveBlock;
}

@end
