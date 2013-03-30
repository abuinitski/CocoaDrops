//
// Created by Arseni Buinitsky
//

#import <Foundation/Foundation.h>

#import "BasicBlocks.h"

@interface NSOperationQueue (CocoaDrops)

+ (void)ensureRunInMainQueue:(VoidBlock)block;

@end