//
//  CDOrderedMutableDictionaryTest.m
//  CDTools
//
//  Created by Arseni Buinitsky on 4/20/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "CDOrderedMutableDictionaryTest.h"
#import "CDOrderedMutableDictionary.h"

@implementation CDOrderedMutableDictionaryTest

- (void)testInitialization {
    NSDictionary *reference = @{ @"war" : @"peace", @"movie" : @"book", @"water" : @"fire" };
    
    NSMutableDictionary *result = [[CDOrderedMutableDictionary alloc] initWithDictionary:reference];
    STAssertTrue([self check:result withReference:reference] , @"Actual result %@ does not match reference %@", result, reference);
    
    result = [[CDOrderedMutableDictionary alloc] init];
    result[@"war"] = @"peace";
    result[@"movie"] = @"book";
    result[@"water"] = @"fire";
    STAssertTrue([self check:result withReference:reference] , @"Actual result %@ does not match reference %@", result, reference);
    
    result = [CDOrderedMutableDictionary dictionary];
    result[@"war"] = @"peace";
    result[@"movie"] = @"book";
    result[@"water"] = @"fire";
    STAssertTrue([self check:result withReference:reference] , @"Actual result %@ does not match reference %@", result, reference);
    
    result = [CDOrderedMutableDictionary dictionaryWithCapacity:3];
    result[@"war"] = @"peace";
    result[@"movie"] = @"book";
    result[@"water"] = @"fire";
    STAssertTrue([self check:result withReference:reference] , @"Actual result %@ does not match reference %@", result, reference);
    
    result = [CDOrderedMutableDictionary dictionaryWithDictionary:reference];
    STAssertTrue([self check:result withReference:reference] , @"Actual result %@ does not match reference %@", result, reference);
}

- (void)testKeyOrdering {
    NSDictionary *reference1 = @{ @"1" : @"a", @"2" : @"b", @"3" : @"c" };
    NSDictionary *reference2 = @{ @"2" : @"b", @"3" : @"c", @"1" : @"a" };
    NSArray *keyReference1 = reference1.allKeys;
    NSArray *keyReference2 = reference2.allKeys;
    
    STAssertTrue([self check:reference1 withReference:reference2], @"check:withReference: implementation is incorrect");
    
    NSMutableDictionary *result1 = [CDOrderedMutableDictionary dictionaryWithDictionary:reference1];
    NSMutableDictionary *result2 = [CDOrderedMutableDictionary dictionaryWithDictionary:reference2];
    STAssertTrue([self check:result1 withReference:result2], @"check:withReference: implementation is incorrect");
    
    for (NSUInteger index = 0; index < 100; ++index) {
        result1 = [CDOrderedMutableDictionary dictionaryWithDictionary:reference1];
        result2 = [CDOrderedMutableDictionary dictionaryWithDictionary:reference2];
        STAssertTrue([result1.allKeys isEqualToArray:keyReference1], @"Keys in result %@ differ from reference ordering %@", result1.allKeys, keyReference1);
        STAssertTrue([result2.allKeys isEqualToArray:keyReference2], @"Keys in result %@ differ from reference ordering %@", result2.allKeys, keyReference2);
    }
}

- (void)testOrderingMutations {
    for (NSUInteger index = 0; index < 100; ++index) {
        NSMutableDictionary *result = [CDOrderedMutableDictionary dictionary];
        
        STAssertTrue([self check:result withReference:@{}], @"Keys ordering is incorrect when mutating dictionary");
        
        result[@"2"] = @"b";
        result[@"1"] = @"a";
        result[@"3"] = @"c";
        
        NSDictionary *reference = @{ @"1" : @"a", @"2" : @"b", @"3" : @"c" };
        NSArray *keyReference = @[ @"2", @"1", @"3" ];
        STAssertTrue([self check:result withReference:reference], @"Mutated result %@ is incorrect (expected %@)", result, reference);
        STAssertTrue([result.allKeys isEqualToArray:keyReference], @"Keys ordering goes wrong when mutated array (got %@; expected %@)", result.allKeys, keyReference);
        
        result[@"1"] = @"z";
        
        reference = @{ @"1" : @"z", @"2" : @"b", @"3" : @"c" };
        keyReference = @[ @"2", @"1", @"3" ];
        STAssertTrue([self check:result withReference:reference], @"Mutated result %@ is incorrect (expected %@)", result, reference);
        STAssertTrue([result.allKeys isEqualToArray:keyReference], @"Keys ordering goes wrong when mutated array (got %@; expected %@)", result.allKeys, keyReference);
        
        result[@"0"] = @"z";
        
        reference = @{ @"1" : @"z", @"2" : @"b", @"3" : @"c", @"0" : @"z" };
        keyReference = @[ @"2", @"1", @"3", @"0" ];
        STAssertTrue([self check:result withReference:reference], @"Mutated result %@ is incorrect (expected %@)", result, reference);
        STAssertTrue([result.allKeys isEqualToArray:keyReference], @"Keys ordering goes wrong when mutated array (got %@; expected %@)", result.allKeys, keyReference);
        
        result[@"2"] = @"y";
        
        reference = @{ @"1" : @"z", @"2" : @"y", @"3" : @"c", @"0" : @"z" };
        keyReference = @[ @"2", @"1", @"3", @"0" ];
        STAssertTrue([self check:result withReference:reference], @"Mutated result %@ is incorrect (expected %@)", result, reference);
        STAssertTrue([result.allKeys isEqualToArray:keyReference], @"Keys ordering goes wrong when mutated array (got %@; expected %@)", result.allKeys, keyReference);
    }
}

- (BOOL)check:(NSDictionary *)dictionary1 withReference:(NSDictionary *)dictionary2 {
    if (dictionary1 == nil || dictionary2 == nil || dictionary1.count != dictionary2.count) {
        return NO;
    }
    
    for (id key in dictionary1.allKeys) {
        id value1 = dictionary1[key];
        id value2 = dictionary2[key];
        
        if (![value1 isEqual:value2]) {
            return NO;
        }
    }
    
    return YES;
}

@end
