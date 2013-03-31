//
// Created by Arseni Buinitsky
//

#import <Foundation/Foundation.h>


@protocol CDDataSource;


typedef void (^CDDataSourceBlock)(id <CDDataSource> dataSource);


@protocol CDDataSource <NSObject>

@property(nonatomic, readonly) NSArray *items;

@property(copy) NSString *name;

- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;

@end