//
// Created by Arseni Buinitsky
//

#import <Foundation/Foundation.h>
#import "CDLoadingDataSource.h"


@protocol CDPagedLoadingDataSource <NSObject, CDLoadingDataSource>

@property (nonatomic, readonly) BOOL hasMoreItems;
@property (nonatomic, readonly) BOOL isLoadingMore;

- (void)loadMore;

@end