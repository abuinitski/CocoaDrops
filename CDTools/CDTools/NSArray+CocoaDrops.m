//
// Created by Arseni Buinitsky
//

#import "NSArray+CocoaDrops.h"


@implementation NSArray (CocoaDrops)

- (void)forEach:(IdBlock)block {
    [self enumerateObjectsUsingBlock:^ (id object, NSUInteger index, BOOL *stop) {
        block(object);
    }];
}

- (NSArray *)subarrayWithIndexSet:(NSIndexSet *)indexSet {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:indexSet.count];

    [self enumerateObjectsAtIndexes:indexSet options:0 usingBlock:^ (id item, NSUInteger index, BOOL *stop) {
        [result addObject:item];
    }];

    return result;
}

- (NSArray *)arrayByRemovingObjectsInIndexSet:(NSIndexSet *)indexSet {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:(self.count - indexSet.count)];

    [self enumerateObjectsUsingBlock:^ (id item, NSUInteger index, BOOL *stop) {
        if (![indexSet containsIndex:index]) {
            [result addObject:item];
        }
    }];

    return result;
}

@end