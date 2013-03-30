//
//  SenTestCase+CDTools.m
//  CDTools
//
//  Created by Arseni Buinitsky on 3/30/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "SenTestCase+CDTools.h"

@implementation SenTestCase (CDTools)

- (void)wait:(NSTimeInterval)interval andGo:(VoidBlock)block {
    [[NSRunLoop currentRunLoop] runUntilDate:[[NSDate date] dateByAddingTimeInterval:interval]];
    block();
}

@end
