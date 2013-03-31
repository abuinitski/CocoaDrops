//
// Created by Arseni Buinitsky
//

#import <Foundation/Foundation.h>
#import "CDDataSource.h"


@protocol CDDeletingDataSource <NSObject, CDDataSource>

- (void)deleteItemsAtIndexPaths:(NSIndexSet *)indexSet;

@end