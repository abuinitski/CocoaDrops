//
// Created by Arseni Buinitsky
//

#import <Foundation/Foundation.h>
#import "CDDeletingDataSource.h"


@protocol CDDeletingDataSourceDelegate <NSObject>

- (void)dataSource:(id<CDDeletingDataSource>)dataSource didDeleteItems:(NSArray *)items atIndexPaths:(NSIndexSet *)indexSet;

@optional

- (void)dataSource:(id<CDDeletingDataSource>)dataSource willDeleteItems:(NSArray *)items atIndexPaths:(NSIndexSet *)indexSet;

- (void)dataSource:(id<CDDeletingDataSource>)dataSource didFailDeletingItems:(NSArray *)items atIndexPaths:(NSIndexSet *)indexSet withError:(NSError *)error;

@end