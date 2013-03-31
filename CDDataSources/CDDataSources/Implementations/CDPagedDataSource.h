//
// Created by Arseni Buinitsky
//

#import <Foundation/Foundation.h>
#import "CDPagedLoadingDataSource.h"
#import "CDDeletingDataSource.h"


@class CDPagedDataSource;


typedef void (^CDPagedLoadingCompletionBlock)(NSArray *items, NSUInteger totalCount);
typedef void (^CDPagedLoadingFailureBlock)(NSError *error);

typedef void (^CDDataSourceDeletionCompletionBlock)();
typedef void (^CDDataSourceDeletionFailureBlock)(NSError *);

/**
* Block to persist deletion. Items will be removed from data source instantly, and this will be called to sync with server.
* Make sure deletion and loading blocks are performed in a single queue.
*/
typedef void (^CDDataSourceDeletionBlock)(NSArray *items, NSIndexSet *indexSet, CDDataSourceDeletionCompletionBlock, CDDataSourceDeletionFailureBlock);

/**
* Block to setup data source for loading data pages. Page numbers count from 1. Called from main thread.
*/
typedef void (^CDPagedLoadingBlock)(NSUInteger pageNumber, NSUInteger pageSize,
        CDPagedLoadingCompletionBlock completion, CDPagedLoadingFailureBlock failure);


/**
* See unit tests for behavior details
*/
@interface CDPagedDataSource : NSObject<CDPagedLoadingDataSource, CDDeletingDataSource>

+ (CDPagedDataSource *)newWithName:(NSString *)name loadingBlock:(CDPagedLoadingBlock)block pageSize:(NSUInteger)pageSize;

+ (CDPagedDataSource *)newWithName:(NSString *)name
                      loadingBlock:(CDPagedLoadingBlock)block
                     deletionBlock:(CDDataSourceDeletionBlock)deletionBlock
                          pageSize:(NSUInteger)pageSize;

@property (nonatomic, copy) CDPagedLoadingBlock loadingBlock;
@property (nonatomic, copy) CDDataSourceDeletionBlock deletionBlock;

@property NSUInteger pageSize;

- (void)forceRefresh;

- (void)cancelRefresh;
- (void)cancelLoadMore;

@end