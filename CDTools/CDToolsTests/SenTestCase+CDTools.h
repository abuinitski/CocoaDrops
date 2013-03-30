//
//  SenTestCase+CDTools.h
//  CDTools
//
//  Created by Arseni Buinitsky on 3/30/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "BasicBlocks.h"

@interface SenTestCase (CDTools)

- (void)wait:(NSTimeInterval)interval andGo:(VoidBlock)block;

@end
