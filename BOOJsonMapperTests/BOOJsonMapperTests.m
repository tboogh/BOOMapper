//
//  BOOJsonMapperTests.m
//  BOOJsonMapperTests
//
//  Created by Tobias Boogh on 26/08/14.
//  Copyright (c) 2014 Tobias Boogh. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOOJsonMapper.h"

// Test classes
#import "BOOUser.h"
#import "BOOOrganization.h"
#import "BOORoot.h"
#import "BOOChannel.h"
#import "BOOMessage.h"

#import "PiranhaChanges.h"
#import "PiranhaPage.h"

@interface BOOJsonMapperTests : XCTestCase <BOOMapperDelegate>
@end

@implementation BOOJsonMapperTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//-(void)testStructureParse{
//    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"structureTest" ofType:@"json"];
//    XCTAssertNotNil(filePath, @"File not found!");
//    
//    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
//    XCTAssertNotNil(filePath, @"Error loading file!");
//    
//    NSError *error = nil;
//    NSDictionary *fileDictionary = [NSJSONSerialization JSONObjectWithData:fileData options:0 error:&error];
//    XCTAssertNil(error, @"Error loading json %@", error.localizedDescription);
//    
//    BOOMapper *mapper = [[BOOMapper alloc] initWithDelegate:self];
//    [mapper.dateFormatter setDateFormat:@"YYYY'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
//    [mapper.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
//    id rootValue = [mapper objectFromDictionary:fileDictionary];
//    XCTAssertTrue([rootValue isKindOfClass:[BOORoot class]], @"Root is not of class BOORoot");
//    BOORoot *root = rootValue;
//    XCTAssertNotNil(root, @"Root is nil, parse failed");
//    XCTAssertNotNil(root.organizations, @"Root object organizations are nil");
//    XCTAssertTrue(root.organizations.count != 0, @"Root Organizations array empty");
//    
//    id organizationValue = root.organizations[0];
//    XCTAssertTrue([organizationValue isKindOfClass:[BOOOrganization class]], @"Organization is not of class BOOOrganization");
//    BOOOrganization *organization = organizationValue;
//    XCTAssertNotNil(organization, @"Organization is nil");
//    XCTAssertTrue([organization.name isEqualToString:@"name"], @"Organization name failed");
//    
//    XCTAssertNotNil(organization.channels, @"Organization channels is nil");
//    XCTAssertTrue(organization.channels.count != 0, "Organization channels is empty");
//    
//    id channelValue = organization.channels[0];
//    XCTAssertTrue([channelValue isKindOfClass:[BOOChannel class]], @"channel is not of class BOOChannel");
//    BOOChannel *channel = channelValue;
//    XCTAssertNotNil(channel, @"Channel is nil");
//    XCTAssertTrue([channel.name isEqualToString:@"name"], @"Channel name failed");
//    XCTAssertNotNil(channel.userIds, @"Channel userIds array is nil");
//    XCTAssertTrue(channel.userIds.count != 0, @"Channel userIds array is empty");
//    
//    for (int i=0; i < channel.userIds.count; ++i){
//        id value = channel.userIds[i];
//        XCTAssertTrue([value isKindOfClass:[NSNumber class]], @"channel.userIds value is not a NSNumber");
//        NSNumber *number = value;
//        NSNumber *compareNumber = @((i + 1) * 1111);
//        XCTAssertTrue([number isEqualToNumber:compareNumber], @"Number is incorrect (%@ == %@)", number, compareNumber);
//    }
//    
//    XCTAssertNotNil(channel.messages, @"Messages are nil");
//    XCTAssertTrue(channel.messages != 0, @"Messages array is empty");
//    NSArray *messages = channel.messages;
//    id messageValue = messages[0];
//    XCTAssertTrue([messageValue isKindOfClass:[BOOMessage class]], @"Message is not of class BOOMessage");
//    BOOMessage *message = messageValue;
//    NSNumber *userId = @4321;
//    NSDate *compareData = [NSDate dateWithTimeIntervalSince1970:0];
//    XCTAssertTrue([message.userId isEqualToNumber:userId], @"Message userId is not correct (%@ == %@)", message.userId, userId);
//    XCTAssertTrue([message.message isEqualToString:@"message"], @"Message is message incorrect");
//    XCTAssertTrue([message.postTime isEqualToDate:compareData], @"Message date is incorrect (%@ == %@)", message.postTime, compareData);
//    XCTAssertNotNil(root.users, @"Root object users are nil");
//}

-(void)testMapperWithoutDelegate{
    BOOMapper *mapper = [[BOOMapper alloc] initWithDelegate:nil];
    //    "LastPublished":"11/15/2013 9:54:27 AM"
    [mapper.dateFormatter setDateFormat:@"MM/dd/yyyy h:mm:ss a"];
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"kraftappen" ofType:@"json"];
    XCTAssertNotNil(filePath, @"File not found!");
    
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    XCTAssertNotNil(filePath, @"Error loading file!");
    
    NSError *error = nil;
    NSDictionary *fileDictionary = [NSJSONSerialization JSONObjectWithData:fileData options:0 error:&error];
    XCTAssertNil(error, @"Error loading json %@", error.localizedDescription);
    
    
    [mapper forClass:[PiranhaPage class] forPropertyNames:@"Regions" mapUsingBlock:^id(id input) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (NSDictionary *arrayDict in input){
            dict[arrayDict[@"Name"]] = arrayDict[@"Body"];
        }
        return dict;
    }];
    
    [mapper resolvePropertiesForClassUsingBlock:^id(__unsafe_unretained Class inClass, NSString *propertyName) {
        if (inClass == nil){
            return [PiranhaChanges class];
        }
        return nil;
    }];
    
    PiranhaChanges *changes = [mapper objectFromDictionary:fileDictionary class:nil];
    
    XCTAssertNotNil(changes, @"Changes not parsed");
    XCTAssertNotNil(changes.Sitemap, @"Sitemap not parsed");
    
}

//
//-(void)testClass{
//    NSDictionary *dict = [BOOMapper propertyAttributesForClass:[PiranhaChanges class]];
//    NSLog(@"%@", dict);
//}

-(Class)mapper:(BOOMapper *)mapper classForPropertyWithName:(NSString *)propertyName parentClass:(__unsafe_unretained Class)parentClass{
    if (parentClass == nil && propertyName == nil){
        return [BOORoot class];
    }
    if (parentClass == [BOORoot class]){
        if ([propertyName isEqualToString:@"users"]){
            return [BOOUser class];
        } else if ([propertyName isEqualToString:@"organizations"]){
            return [BOOOrganization class];
        }
    } else if (parentClass == [BOOOrganization class]){
        if ([propertyName isEqualToString:@"channels"]){
            return [BOOChannel class];
        }
    } else if (parentClass == [BOOChannel class]){
        if ([propertyName isEqualToString:@"messages"]){
            return [BOOMessage class];
        }
    }
    return nil;
}

-(id)mapper:(BOOMapper *)mapper instanceForClass:(__unsafe_unretained Class)class{
    return [[class alloc] init];
    return nil;
}

@end
