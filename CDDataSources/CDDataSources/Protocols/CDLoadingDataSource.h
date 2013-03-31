//
// Created by Arseni Buinitsky
//

#import <Foundation/Foundation.h>
#import "CDDataSource.h"


@protocol CDLoadingDataSource <NSObject, CDDataSource>

@property (nonatomic, readonly) NSDate *lastRefreshDate;
@property (nonatomic, readonly) BOOL isRefreshing;

- (void)refresh;

@end