//
// Created by Arseni Buinitsky
//

#import "CDPagedDataSource.h"
#import "CDPagedLoadingDataSourceDelegate.h"
#import "CDDeletingDataSourceDelegate.h"

#import <CocoaDrops/CocoaDrops.h>


@interface CDPagedDataSource ()

- (void)startLoadingMore;
- (void)doAppendItems:(NSArray *)newItems newTotalCount:(NSUInteger)newTotalCount;
- (void)doFailAppendingItems:(NSError *)error;

- (void)startRefreshing;
- (void)doRefreshItems:(NSArray *)newItems newTotalCount:(NSUInteger)newTotalCount;
- (void)doFailRefreshingItems:(NSError *)error;

@end


@implementation CDPagedDataSource {
@private
    CDDelegateContainer *delegates;
    NSArray *items;

    NSDate *lastRefreshDate;
    NSObject *refreshHandle;
    NSObject *loadMoreHandle;
    NSUInteger totalItemsCount;
}

@synthesize name = _name;

#pragma mark - Lifecycle and configuration

+ (CDPagedDataSource *)newWithName:(NSString *)name loadingBlock:(CDPagedLoadingBlock)block pageSize:(NSUInteger)pageSize {
    return [self newWithName:name loadingBlock:block deletionBlock:nil pageSize:pageSize];
}

+ (CDPagedDataSource *)newWithName:(NSString *)name loadingBlock:(CDPagedLoadingBlock)block deletionBlock:(CDDataSourceDeletionBlock)deletionBlock
                          pageSize:(NSUInteger)pageSize {
    CDPagedDataSource *dataSource = [[CDPagedDataSource alloc] init];
    dataSource.name = name;
    dataSource.loadingBlock = block;
    dataSource.deletionBlock = deletionBlock;
    dataSource.pageSize = pageSize;
    return dataSource;
}


- (id)init {
    self = [super init];
    if (self) {
        delegates = [[CDDelegateContainer alloc] init];
        [delegates ensureProtocol:@protocol(CDPagedLoadingDataSourceDelegate)];

        items = [NSArray array];
        lastRefreshDate = nil;
        refreshHandle = nil;
        loadMoreHandle = nil;
        totalItemsCount = NSUIntegerMax;
    }
    return self;
}

- (void)addDelegate:(id)delegate {
    [delegates addDelegate:delegate];
}

- (void)removeDelegate:(id)delegate {
    [delegates removeDelegate:delegate];
}

- (void)setDeletionBlock:(CDDataSourceDeletionBlock)deletionBlock {
    if (deletionBlock) {
        _deletionBlock = [deletionBlock copy];
        [delegates ensureProtocol:@protocol(CDDeletingDataSourceDelegate)];
    }
}

#pragma mark - Properties

- (BOOL)hasMoreItems {
    return items.count < totalItemsCount;
}

- (BOOL)isLoadingMore {
    return loadMoreHandle != nil;
}

- (BOOL)isRefreshing {
    return refreshHandle != nil;
}

- (NSDate *)lastRefreshDate {
    return lastRefreshDate;
}

- (NSArray *)items {
    return items ? items : [NSArray array];
}

#pragma mark - Actions

- (void)loadMore {
    if (self.hasMoreItems) {
        if (items.count == 0) {
            [self refresh];
        } else if (refreshHandle == nil && loadMoreHandle == nil) {
            [self startLoadingMore];
        }
    }
}

- (void)refresh {
    if (refreshHandle == nil) {
        [self startRefreshing];
    }
}

- (void)forceRefresh {
    [self startRefreshing];
}

- (void)cancelRefresh {
    if (refreshHandle) {
        refreshHandle = nil;
        [delegates send:@selector(dataSourceDidEndLoading:) withParam:self];
    }
}

- (void)cancelLoadMore {
    if (loadMoreHandle) {
        loadMoreHandle = nil;
        [delegates send:@selector(dataSourceDidEndLoadingItemsToAppend:) withParam:self];
    }
}

#pragma mark - Internals - Deletion

- (void)deleteItemsAtIndexPaths:(NSIndexSet *)indexSet {
    if (indexSet.count && self.deletionBlock) {
        refreshHandle = nil;
        loadMoreHandle = nil;

        NSArray *itemsToDelete = [items subarrayWithIndexSet:indexSet];

        [delegates send:@selector(dataSource:willDeleteItems:atIndexPaths:) withParam1:self param2:itemsToDelete param3:indexSet];

        items = [items arrayByRemovingObjectsInIndexSet:indexSet];
        if (totalItemsCount < NSUIntegerMax) {
            totalItemsCount -= itemsToDelete.count;
        }

        [delegates send:@selector(dataSource:didDeleteItems:atIndexPaths:) withParam1:self param2:itemsToDelete param3:indexSet];

        CDDataSourceDeletionCompletionBlock completion = ^ {
            
        };

        CDDataSourceDeletionFailureBlock failure = ^ (NSError *error) {
            [delegates send:@selector(dataSource:didFailDeletingItems:atIndexPaths:withError:)
                 withParam1:self param2:itemsToDelete param3:indexSet param4:error];
            [self forceRefresh];
        };

        self.deletionBlock(itemsToDelete, indexSet, completion, failure);
    }
}

#pragma mark - Internals - Load more

- (void)startLoadingMore {
    [self cancelLoadMore];

    NSObject *currentLoadMoreHandle = [[NSObject alloc] init];
    loadMoreHandle = currentLoadMoreHandle;

    __weak CDPagedDataSource *weakSelf = self;
    __block BOOL complete = NO;
    __block BOOL immediate = YES;

    CDPagedLoadingCompletionBlock completion = ^(NSArray *newItems, NSUInteger newTotalCount) {
        [NSOperationQueue ensureRunInMainQueue:^{
            complete = YES;

            CDPagedDataSource *me = weakSelf;

            if (me && currentLoadMoreHandle == me->loadMoreHandle) {
                if (!immediate) {
                    [me->delegates send:@selector(dataSourceDidEndLoadingItemsToAppend:) withParam:me];
                }
                [me doAppendItems:newItems newTotalCount:newTotalCount];
            }
        }];
    };

    CDPagedLoadingFailureBlock failure = ^(NSError *error) {
        [NSOperationQueue ensureRunInMainQueue:^{
            complete = YES;

            CDPagedDataSource *me = weakSelf;

            if (me && currentLoadMoreHandle == me->loadMoreHandle) {
                if (!immediate) {
                    [me->delegates send:@selector(dataSourceDidEndLoadingItemsToAppend:) withParam:me];
                }
                [me doFailAppendingItems:error];
            }
        }];
    };

    self.loadingBlock(items.count / self.pageSize + 1, self.pageSize, completion, failure);

    if (!complete) {
        immediate = NO;
        [delegates send:@selector(dataSourceDidBeginLoadingItemsToAppend:) withParam:self];
    }
}

- (void)doAppendItems:(NSArray *)newItems newTotalCount:(NSUInteger)newTotalCount {
    loadMoreHandle = nil;

    [delegates send:@selector(dataSource:willAppendItems:) withParam1:self param2:newItems];

    items = [items arrayByAddingObjectsFromArray:newItems];
    totalItemsCount = newTotalCount;
    if (newItems.count < self.pageSize) {
        totalItemsCount = items.count;
    }

    [delegates send:@selector(dataSource:didAppendItems:) withParam1:self param2:newItems];
}

- (void)doFailAppendingItems:(NSError *)error {
    loadMoreHandle = nil;
    [delegates send:@selector(dataSource:didFailAppendingItems:) withParam1:self param2:error];
}

#pragma mark - Internals - Refresh

- (void)startRefreshing {
    [self cancelRefresh];
    [self cancelLoadMore];

    NSObject *currentRefreshHandle = [[NSObject alloc] init];
    refreshHandle = currentRefreshHandle;

    __weak CDPagedDataSource *weakSelf = self;
    __block BOOL complete = NO;
    __block BOOL immediate = YES;

    CDPagedLoadingCompletionBlock completion = ^(NSArray *newItems, NSUInteger newTotalCount) {
        [NSOperationQueue ensureRunInMainQueue:^{
            complete = YES;

            CDPagedDataSource *me = weakSelf;

            if (me && currentRefreshHandle == me->refreshHandle) {
                if (!immediate) {
                    [me->delegates send:@selector(dataSourceDidEndLoading:) withParam:me];
                }
                [me doRefreshItems:newItems newTotalCount:newTotalCount];
            }
        }];
    };

    CDPagedLoadingFailureBlock failure = ^(NSError *error) {
        [NSOperationQueue ensureRunInMainQueue:^{
            complete = YES;

            CDPagedDataSource *me = weakSelf;

            if (me && currentRefreshHandle == me->refreshHandle) {
                if (!immediate) {
                    [me->delegates send:@selector(dataSourceDidEndLoading:) withParam:me];
                }
                [me doFailRefreshingItems:error];
            }
        }];
    };

    self.loadingBlock(1, self.pageSize, completion, failure);

    if (!complete) {
        immediate = NO;
        [delegates send:@selector(dataSourceDidBeginLoading:) withParam:self];
    }
}

- (void)doRefreshItems:(NSArray *)newItems newTotalCount:(NSUInteger)newTotalCount {
    refreshHandle = nil;

    [delegates send:@selector(dataSourceWillRefresh:) withParam:self];

    items = [newItems copy];
    totalItemsCount = newTotalCount;
    if (newItems.count < self.pageSize) {
        totalItemsCount = items.count;
    }

    [delegates send:@selector(dataSourceDidRefresh:) withParam:self];
}

- (void)doFailRefreshingItems:(NSError *)error {
    refreshHandle = nil;
    [delegates send:@selector(dataSource:didFailRefreshing:) withParam1:self param2:error];
}

@end