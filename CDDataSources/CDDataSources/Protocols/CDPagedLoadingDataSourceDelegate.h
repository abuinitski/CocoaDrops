//
// Created by Arseni Buinitsky
//

#import <Foundation/Foundation.h>
#import "CDLoadingDataSourceDelegate.h"


@protocol CDPagedLoadingDataSource;


@protocol CDPagedLoadingDataSourceDelegate <NSObject, CDLoadingDataSourceDelegate>
@optional

- (void)dataSourceDidBeginLoadingItemsToAppend:(id<CDPagedLoadingDataSource>)dataSource;
- (void)dataSourceDidEndLoadingItemsToAppend:(id<CDPagedLoadingDataSource>)dataSource;

- (void)dataSource:(id<CDPagedLoadingDataSource>)dataSource willAppendItems:(NSArray *)items;
- (void)dataSource:(id<CDPagedLoadingDataSource>)dataSource didAppendItems:(NSArray *)items;
- (void)dataSource:(id<CDPagedLoadingDataSource>)dataSource didFailAppendingItems:(NSError *)error;

@end