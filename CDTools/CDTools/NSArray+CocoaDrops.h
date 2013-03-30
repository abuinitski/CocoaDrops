//
// Created by Arseni Buinitsky
//

#import <Foundation/Foundation.h>

#import "CDBasicBlocks.h"

@interface NSArray (CocoaDrops)

- (void)forEach:(IdBlock)block;

- (NSArray *)subarrayWithIndexSet:(NSIndexSet *)indexSet;

- (NSArray *)arrayByRemovingObjectsInIndexSet:(NSIndexSet *)indexSet;

@end