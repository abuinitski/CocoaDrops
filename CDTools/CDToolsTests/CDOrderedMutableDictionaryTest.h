//
//  CDOrderedMutableDictionaryTest.h
//  CDTools
//
//  Created by Arseni Buinitsky on 4/20/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface CDOrderedMutableDictionaryTest : SenTestCase

- (BOOL)check:(NSDictionary *)dictionary1 withReference:(NSDictionary *)dictionary2;

@end
