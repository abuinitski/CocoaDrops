//
//  CDPagedDataSourceTests.m
//  CDPagedDataSourceTests
//
//  Created by Arseni Buinitsky on 3/30/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "CDPagedDataSourceTests.h"
#import "CDPagedDataSource.h"
#import "SenTestCase+CDTools.h"
#import "CDPagedLoadingDataSourceDelegate.h"

#import <CocoaDrops/CocoaDrops.h>
#import <OCMock/OCMock.h>


@interface DataSourceTestingLoader : NSObject

- (void)loadPage:(NSUInteger)pageNumber size:(NSUInteger)pageSize
      completion:(CDPagedLoadingCompletionBlock)completion failure:(CDPagedLoadingFailureBlock)failure;

- (void)deleteItemsWithCompletion:(CDDataSourceDeletionCompletionBlock)completion failure:(CDDataSourceDeletionFailureBlock)failure;

- (void)postOperation:(NSString *)name completion:(VoidBlock)completion failure:(VoidBlock)failure;

- (void)expectOperation:(NSString *)operation;
- (void)registerOperation:(NSString *)operation;
- (void)verify;

@property BOOL failOperations;

@property NSUInteger totalItemsOnBackend;

@property (nonatomic, readonly) CDPagedLoadingBlock loadingBlock;
@property (nonatomic, readonly) CDDataSourceDeletionBlock deletionBlock;

@end

@implementation DataSourceTestingLoader {
    NSMutableArray *expectedOperations;
}

- (id)init {
    self = [super init];
    if (self) {
        __weak DataSourceTestingLoader *weakSelf = self;

        _loadingBlock = ^ (NSUInteger pageNumber, NSUInteger pageSize,
                CDPagedLoadingCompletionBlock completion, CDPagedLoadingFailureBlock failure) {
            [weakSelf loadPage:pageNumber size:pageSize completion:completion failure:failure];
        };

        _deletionBlock = ^ (NSArray *items, NSIndexSet *indexSet, CDDataSourceDeletionCompletionBlock completion, CDDataSourceDeletionFailureBlock failure) {
            [weakSelf deleteItemsWithCompletion:completion failure:failure];
        };
    }
    return self;
}

- (void)expectOperation:(NSString *)operation {
    if (!expectedOperations) {
        expectedOperations = [NSMutableArray array];
    }
    [expectedOperations addObject:operation];
}

- (void)registerOperation:(NSString *)operation {
    if (expectedOperations) {
        NSUInteger index = [expectedOperations indexOfObject:operation];
        if (index != NSNotFound) {
            [expectedOperations removeObjectAtIndex:index];
        } else {
            [NSException raise:@"DataSourceTestingLoaderException" format:@"Undexpected operation: %@", operation];
        }
    }
}

- (void)verify {
    if (expectedOperations && expectedOperations.count) {
        [NSException raise:@"DataSourceTestingLoaderException" format:@"Expected operations did not occur: %@", expectedOperations];
    }
}

- (void)loadPage:(NSUInteger)pageNumber size:(NSUInteger)pageSize completion:(CDPagedLoadingCompletionBlock)completion
         failure:(CDPagedLoadingFailureBlock)failure {

    NSString *name = [NSString stringWithFormat:@"load-%d", pageNumber];

    [self postOperation:name completion:^{
        
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:pageSize];

        for (NSUInteger index = (pageNumber - 1) * pageSize; index < self.totalItemsOnBackend && array.count < pageSize; ++index) {
            [array addObject:[NSNumber numberWithUnsignedInteger:(index + 1)]];
        }

        [self registerOperation:name];
        completion(array, self.totalItemsOnBackend);
    } failure:^{
        [self registerOperation:name];
        failure([NSError errorWithDomain:@"Test" code:100 userInfo:nil]);
    }];
}

- (void)deleteItemsWithCompletion:(CDDataSourceDeletionCompletionBlock)completion failure:(CDDataSourceDeletionFailureBlock)failure {

    NSString *name = @"delete";

    [self registerOperation:name];

    [self postOperation:name completion:^ {
        completion();
    } failure:^ {
        failure([NSError errorWithDomain:@"Test" code:200 userInfo:nil]);
    }];
}

- (void)postOperation:(NSString *)name completion:(VoidBlock)completion failure:(VoidBlock)failure {
    if (self.failOperations) {
        failure();
    } else {
        completion();
    }
}

@end



@interface DataSourceTestingBackgroundLoader : DataSourceTestingLoader

- (void)triggerOperationCompletion;

@end


@implementation DataSourceTestingBackgroundLoader {
    NSOperationQueue *queue;
    NSMutableArray *locks;
}

- (id)init {
    self = [super init];
    if (self) {
        queue = [[NSOperationQueue alloc] init];
        queue.name = @"DataSourceTestingBackgroundLoader";
        locks = [NSMutableArray array];
    }
    return self;
}

- (void)postOperation:(NSString *)name completion:(VoidBlock)completion failure:(VoidBlock)failure {
    NSLock *lock = [[NSLock alloc] init];
    [locks addObject:lock];
    [lock lock];

    [queue addOperationWithBlock:^ {
        [lock lock];
        [lock unlock];

        if (self.failOperations) {
            failure();
        } else {
            completion();
        }
    }];
}

- (void)triggerOperationCompletion {
    if (locks.count) {
        NSLock *lock = [locks lastObject];
        [locks removeLastObject];
        [lock unlock];
    } else {
        [NSException raise:@"DataSourceTestingBackgroundLoaderException" format:@"No pending opertations to trigger completion for"];
    }
}

@end



@implementation CDPagedDataSourceTests

#pragma mark - Helperts

- (void)checkMainThread {
    STAssertEqualObjects([NSThread currentThread], [NSThread mainThread], @"data source delegate methods called in background thread");
}

#pragma mark - Tests

- (void)testSimpleLoader {
    DataSourceTestingLoader *loader = [[DataSourceTestingLoader alloc] init];
    loader.totalItemsOnBackend = 20;
    
    CDPagedDataSource *dataSource = [CDPagedDataSource newWithName:@"dataSource" loadingBlock:loader.loadingBlock pageSize:10];

    [loader expectOperation:@"load-1"];
    [dataSource refresh];
    [loader verify];

    [loader expectOperation:@"load-1"];
    [dataSource refresh];
    [loader verify];

    [loader expectOperation:@"load-2"];
    [dataSource loadMore];
    [loader verify];
    
    dataSource = [CDPagedDataSource newWithName:@"dataSource" loadingBlock:loader.loadingBlock deletionBlock:loader.deletionBlock pageSize:10];
    [loader expectOperation:@"load-1"];
    [loader expectOperation:@"load-2"];
    [loader expectOperation:@"delete"];
    
    [dataSource loadMore];
    [dataSource loadMore];
    STAssertTrue(dataSource.items.count == 20, @"expected 20 items after loading, seeing %d", dataSource.items.count);
    
    [dataSource deleteItemsAtIndexPaths:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(10, 10)]];
    STAssertTrue(dataSource.items.count == 10, @"expected 10 items after deletion, seeing %d", dataSource.items.count);
    
    NSArray *expectedArray = @[ @1, @2, @3, @4, @5, @6, @7, @8, @9, @10 ];
    STAssertTrue([expectedArray isEqualToArray:dataSource.items], @"expected to see %@ after deletion, seeing %@", expectedArray, dataSource.items);
    
    [loader verify];
}

- (void)testBackgroundLoader {
    DataSourceTestingBackgroundLoader *loader = [[DataSourceTestingBackgroundLoader alloc] init];
    loader.totalItemsOnBackend = 20;
    
    CDPagedDataSource *dataSource = [CDPagedDataSource newWithName:@"dataSource" loadingBlock:loader.loadingBlock deletionBlock:loader.deletionBlock pageSize:10];
    
    [loader expectOperation:@"load-1"];
    [dataSource refresh];
    [loader triggerOperationCompletion];
    
    [self wait:0.1 andGo:^ {
        [loader verify];
    }];
    
    [loader expectOperation:@"load-1"];
    [loader expectOperation:@"load-2"];
    [dataSource refresh];
    [loader triggerOperationCompletion];
    [self wait:0.1 andGo:^ {
        [dataSource loadMore];
        [loader triggerOperationCompletion];
        [self wait:0.1 andGo:^ {
            [loader verify];
            
            [loader expectOperation:@"delete"];
            [dataSource deleteItemsAtIndexPaths:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(10, 10)]];
            [loader triggerOperationCompletion];
            [self wait:0.1 andGo:^ {
                [loader verify];
            }];
        }];
    }];
}

- (void)testInitialState {
    DataSourceTestingBackgroundLoader *loader = [[DataSourceTestingBackgroundLoader alloc] init];
    loader.totalItemsOnBackend = 20;
    
    CDPagedDataSource *dataSource = [CDPagedDataSource newWithName:@"dataSource" loadingBlock:loader.loadingBlock deletionBlock:loader.deletionBlock pageSize:10];
    
    STAssertFalse(dataSource.isRefreshing, nil);
    STAssertFalse(dataSource.isLoadingMore, nil);
    
    [dataSource loadMore];
    STAssertTrue(dataSource.isRefreshing, nil);
    STAssertTrue(dataSource.isLoadingMore, nil);
}

- (void)testDelegateEvents {
    DataSourceTestingBackgroundLoader *loader = [[DataSourceTestingBackgroundLoader alloc] init];
    loader.totalItemsOnBackend = 20;
    
    CDPagedDataSource *dataSource = [CDPagedDataSource newWithName:@"dataSource" loadingBlock:loader.loadingBlock pageSize:5];
    
    id delegateMock = [OCMockObject mockForProtocol:@protocol(CDPagedLoadingDataSourceDelegate)];
    id expectDelegateMock = [OCMockObject mockForProtocol:@protocol(CDPagedLoadingDataSourceDelegate)];
    
    [dataSource addDelegate:delegateMock];
    [dataSource addDelegate:expectDelegateMock];

    [[[delegateMock stub] andCall:@selector(checkMainThread) onObject:self] dataSourceWillRefresh:dataSource];
    [[[delegateMock stub] andCall:@selector(checkMainThread) onObject:self] dataSourceDidRefresh:dataSource];
    [[[delegateMock stub] andCall:@selector(checkMainThread) onObject:self] dataSource:dataSource willAppendItems:[OCMArg any]];
    [[[delegateMock stub] andCall:@selector(checkMainThread) onObject:self] dataSource:dataSource didAppendItems:[OCMArg any]];
    [[[delegateMock stub] andCall:@selector(checkMainThread) onObject:self]
            dataSourceDidBeginLoadingItemsToAppend:dataSource];
    [[[delegateMock stub] andCall:@selector(checkMainThread) onObject:self]
            dataSourceDidEndLoadingItemsToAppend:dataSource];
    [[[delegateMock stub] andCall:@selector(checkMainThread) onObject:self] dataSourceDidBeginLoading:dataSource];
    [[[delegateMock stub] andCall:@selector(checkMainThread) onObject:self] dataSourceDidEndLoading:dataSource];
    
    [[expectDelegateMock expect] dataSourceDidBeginLoading:dataSource];
    [dataSource refresh];
    [expectDelegateMock verify];
    
    [[expectDelegateMock expect] dataSourceDidEndLoading:dataSource];
    [[expectDelegateMock expect] dataSourceWillRefresh:dataSource];
    [[expectDelegateMock expect] dataSourceDidRefresh:dataSource];
    [loader triggerOperationCompletion];

    [self wait:0.1 andGo:^ {
        [delegateMock verify];
        [expectDelegateMock verify];

        [[expectDelegateMock expect] dataSourceDidBeginLoadingItemsToAppend:dataSource];
        [dataSource loadMore];
        [expectDelegateMock verify];
        
        [[expectDelegateMock expect] dataSourceDidEndLoadingItemsToAppend:dataSource];
        [[expectDelegateMock expect] dataSource:dataSource willAppendItems:[OCMArg checkWithBlock:^ BOOL (id item) {
            return [item isKindOfClass:[NSArray class]] && [item isEqualToArray:@[@6, @7, @8, @9, @10]];
        }]];
        [[expectDelegateMock expect] dataSource:dataSource didAppendItems:[OCMArg checkWithBlock:^ BOOL (id item) {
            return [item isKindOfClass:[NSArray class]] && [item isEqualToArray:@[@6, @7, @8, @9, @10]];
        }]];
        [loader triggerOperationCompletion];
        
        [self wait:0.1 andGo:^ {
            [delegateMock verify];
            [expectDelegateMock verify];
        }];
    }];
}

// no sending begin/end loading events when immediate loading
// did begin/end loading/appending always match

@end
