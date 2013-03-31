//
// Created by Arseni Buinitsky
//

#import <Foundation/Foundation.h>


@protocol CDLoadingDataSource;


@protocol CDLoadingDataSourceDelegate <NSObject>
@required

- (void)dataSourceDidRefresh:(id<CDLoadingDataSource>)dataSource;

@optional

- (void)dataSourceDidBeginLoading:(id<CDLoadingDataSource>)dataSource;
- (void)dataSourceDidEndLoading:(id<CDLoadingDataSource>)dataSource;

- (void)dataSourceWillRefresh:(id<CDLoadingDataSource>)dataSource;
- (void)dataSource:(id<CDLoadingDataSource>)dataSource didFailRefreshing:(NSError *)error;

@end