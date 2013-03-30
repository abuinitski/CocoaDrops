//
// Created by Arseni Buinitsky
//

#import <Foundation/Foundation.h>

#import "CDBasicBlocks.h"

@interface NSOperationQueue (CocoaDrops)

+ (void)ensureRunInMainQueue:(VoidBlock)block;

@end