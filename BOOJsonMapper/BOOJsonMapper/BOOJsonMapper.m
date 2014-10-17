//
//  BOOJsonMapper.m
//  BOOJsonMapper
//
//  Created by Tobias Boogh on 26/08/14.
//  Copyright (c) 2014 Tobias Boogh. All rights reserved.
//

#import "BOOJsonMapper.h"
#import <objc/runtime.h>

NSString * const BOOMapperInstanceCompleteNotification = @"BOOMapperInstanceCompleteNotification";

@implementation BOOMapperPropertyInfo
-(NSString *)description{
    return [NSString stringWithFormat:@"%@ %@", self.name, self.className];
}
@end

@interface BOOMapper()
@property (nonatomic, strong) NSMutableDictionary *propertyMapperBlocks;
@property (nonatomic, copy) BOOMapperPropertyMapperResolveClassBlock resolveBlock;
@property (nonatomic, copy) BOOMapperPropertyMapperClassInstanceBlock instanceBlock;
@end

@implementation BOOMapper

-(NSDateFormatter *)dateFormatter{
    if (_dateFormatter == nil){
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

-(NSMutableDictionary *)propertyMapperBlocks{
    if (_propertyMapperBlocks == nil){
        _propertyMapperBlocks = [[NSMutableDictionary alloc] init];
    }
    return _propertyMapperBlocks;
}

-(id)objectFromDictionary:(NSDictionary *)dictionary{
    return [self objectFromDictionary:dictionary class:nil];
}

-(instancetype)instanceForClass:(Class)class{
    id object = nil;
    if (self.instanceBlock != nil){
        object = self.instanceBlock(class);
    }
    if (object == nil){
        object = [[class alloc] init];
    }
    return object;
}

-(id)objectFromDictionary:(NSDictionary *)dictionary class:(Class)class{    
    id object = nil;
    if (class == nil){
        class = [self classForPropertyInfo:nil parentClass:nil];
    }
    object = [self instanceForClass:class];
    
    NSArray *propertyAttributes = [BOOMapper propertyAttributesForClass:class];
    
    for (NSString *key in [BOOMapper propertyNamesForClass:class]) {
        __block BOOMapperPropertyInfo *info = nil;
        [propertyAttributes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BOOMapperPropertyInfo *propertyInfo = obj;
            if ([propertyInfo.name isEqualToString:key]){
                info = propertyInfo;
                *stop = YES;
            }
        }];
        id value = nil;
        if (info != nil){
            id dictValue;
            NSDictionary *propertyMapperBlockDict = self.propertyMapperBlocks[NSStringFromClass(class)];
            if (propertyMapperBlockDict != nil){
                BOOMapperPropertyMapperBlock block = propertyMapperBlockDict[key];
                if (block != nil) {
                    dictValue = block(dictionary);
                }
            }
            if (dictValue == nil){
                 dictValue = [dictionary valueForKey:key];
            }
            
            if (dictValue == nil){
                continue;
            }
            value = [self convertedValue:dictValue forProperty:info parentClass:class];
            
            if (info.isWeak){
                NSLog(@"Warning: Property %@ is a weak reference", info.name);
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
            } else {
                [object setValue:value forKey:info.name];
            }
        }
    }
    // Notify
    return object;
}

-(NSArray *)arrayFromCSVFile:(NSString *)file withClass:(Class)csvClass ignoreHeaderRow:(BOOL)ignoreHeader{
    NSMutableArray *csvArray = [[NSMutableArray alloc] init];
    __block int row = 0;
    [file enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        if (row == 0 && ignoreHeader){
            
        } else {
            id rowObject = [self instanceForClass:csvClass];
            NSArray *propertyInfos = [BOOMapper propertyAttributesForClass:csvClass];
            NSArray *components = [line componentsSeparatedByString:@";"];
            for (int i=0; i < propertyInfos.count; ++i){
                BOOMapperPropertyInfo *info = propertyInfos[i];
                id value = nil;
                if (i < components.count){
                    value = [self convertedValue:components[i] forProperty:info parentClass:csvClass];
                }
                NSDictionary *propertyMapperBlockDict = self.propertyMapperBlocks[NSStringFromClass(csvClass)];
                if (propertyMapperBlockDict != nil){
                    BOOMapperPropertyMapperBlock block = propertyMapperBlockDict[info.name];
                    if (block != nil) {
                        value = block(value);
                    }
                }
                if (value != nil){
                    [rowObject setValue:value forKey:info.name];
                }
            }
            [csvArray addObject:rowObject];
            // Notify
        }
        ++row;
    }];
    return csvArray;
}

-(id)convertNSNumber:(id)value{
    if ([value isKindOfClass:[NSString class]]){
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        return [numberFormatter numberFromString:value];
    } else if ([value isKindOfClass:[NSNumber class]]){
        return value;
    }
    NSLog(@"Unsupported conversion: %@ to NSNumber", NSStringFromClass([value class]));
    return nil;
}

-(id)convertNSString:(id)value{
    if ([value isKindOfClass:[NSString class]]){
        return value;
    } else if ([value isKindOfClass:[NSNumber class]]){
        return [value stringValue];
    } else if ([value isKindOfClass:[NSNull class]]){
        return nil;
    }
    NSLog(@"Unsupported conversion: %@ to NSString", NSStringFromClass([value class]));
    return nil;
}

-(id)convertNSSet:(id)value propertyInfo:(BOOMapperPropertyInfo *)propertyInfo parentClass:(Class)parentClass{
    NSMutableSet *set = [[NSMutableSet alloc] init];
    if ([value isKindOfClass:[NSArray class]]){
        for (id arrayValue in value) {
            id convertedArrayValue = value;
            if ([arrayValue isKindOfClass:[NSDictionary class]]){
                convertedArrayValue = [self convertedValue:arrayValue forProperty:propertyInfo parentClass:parentClass];
            }
            if (convertedArrayValue != nil){
                [set addObject:convertedArrayValue];
            }
        }
    }
    return set;
}

-(id)convertNSOrderedSet:(id)value propertyInfo:(BOOMapperPropertyInfo *)propertyInfo parentClass:(Class)parentClass{
    NSMutableOrderedSet *set = [[NSMutableOrderedSet alloc] init];
    if ([value isKindOfClass:[NSArray class]]){
        for (id arrayValue in value) {
            id convertedArrayValue = value;
            if ([arrayValue isKindOfClass:[NSDictionary class]]){
                convertedArrayValue = [self convertedValue:arrayValue forProperty:propertyInfo parentClass:parentClass];
            }
            if (convertedArrayValue != nil){
                [set addObject:convertedArrayValue];
            }
        }
    }
    return set;
}

-(id)convertNSArray:(id)value propertyInfo:(BOOMapperPropertyInfo *)propertyInfo parentClass:(Class)parentClass{
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
}

-(id)convertNSDate:(id)value{
    if ([value isKindOfClass:[NSDate class]]){
        return value;
    } else if ([value isKindOfClass:[NSString class]]){
        NSDate *date = [self.dateFormatter dateFromString:value];
        return date;
    }
    
    NSLog(@"Unsupported conversion: %@ to NSDate", NSStringFromClass([value class]));
    return nil;
}

-(id)classForPropertyInfo:(BOOMapperPropertyInfo *)propertyInfo parentClass:(Class)parentClass{
    Class class = nil;
    if (self.resolveBlock != nil && class == nil){
        class = self.resolveBlock(parentClass, propertyInfo.name);
    }
    if (class == nil){
        if (![propertyInfo.protocolName isEqualToString:@""] && propertyInfo.protocolName != nil){
            class = NSClassFromString(propertyInfo.protocolName);
        }
    }
    if (class == nil){
        class = NSClassFromString(propertyInfo.className);
    }
    
    return class;
}

-(id)convertNSDictionary:(id)value propertyInfo:(BOOMapperPropertyInfo *)propertyInfo parentClass:(Class)parentClass{
    Class class = [self classForPropertyInfo:propertyInfo parentClass:parentClass];
    if (class == nil){
        NSLog(@"No class returned for %@, returning dictionary value", propertyInfo.name);
        return value;
    }
    if ([value isKindOfClass:class]){
        return value;
    }
    id object = [self objectFromDictionary:value class:class];
    return object;
}

-(id)convertedValue:(id)value forProperty:(BOOMapperPropertyInfo *)propertyInfo parentClass:(Class)parentClass{
    if ([value isKindOfClass:[NSDictionary class]]){
        return [self convertNSDictionary:value propertyInfo:propertyInfo parentClass:parentClass];
    } else {
        Class propertyClass = NSClassFromString(propertyInfo.className);
        if (propertyClass == [NSNumber class]){
            return [self convertNSNumber:value];
        } else if (propertyClass == [NSString class]){
            return [self convertNSString:value];
        } else if (propertyClass == [NSSet class] || propertyClass == [NSMutableSet class]){
            return [self convertNSSet:value propertyInfo:propertyInfo parentClass:parentClass];
        } else if (propertyClass == [NSOrderedSet class] || propertyClass == [NSMutableOrderedSet class]){
            return [self convertNSOrderedSet:value propertyInfo:propertyInfo parentClass:parentClass];
        } else if (propertyClass == [NSArray class] || propertyClass == [NSMutableArray class]){
            return [self convertNSArray:value propertyInfo:propertyInfo parentClass:parentClass];
        } else if (propertyClass == [NSDate class]){
            return [self convertNSDate:value];
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

+(NSArray *)propertyAttributesForClass:(Class)class{
    NSMutableArray *propertyInfoArray = [[NSMutableArray alloc] init];
    unsigned int count;
    objc_property_t *list = nil;
    list = class_copyPropertyList(class, &count);
    for (int i=0; i < count; ++i){
        objc_property_t prop = list[i];
        const char *name = property_getName(prop);
        
        NSString *attributes = [NSString stringWithCString:property_getAttributes(prop) encoding:NSUTF8StringEncoding];
        
        BOOMapperPropertyInfo *info = [[BOOMapperPropertyInfo alloc] init];
        info.name = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        [propertyInfoArray addObject:info];
        
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
    return propertyInfoArray;
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

-(void)instantiateClassesWithBlock:(BOOMapperPropertyMapperClassInstanceBlock)instanceBlock{
    self.instanceBlock = instanceBlock;
}

@end
