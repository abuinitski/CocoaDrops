//
// Created by Arseni Buinitsky
//

#import "NSOperationQueue+CocoaDrops.h"


@implementation NSOperationQueue (CocoaDrops)

+ (void)ensureRunInMainQueue:(VoidBlock)block {
    if ([NSOperationQueue mainQueue] == [NSOperationQueue currentQueue]) {
        block();
    } else {
        [[NSOperationQueue mainQueue] addOperationWithBlock:block];
    }
}

@end