//
// Created by Arseni Buinitsky
//

typedef void (^VoidBlock)(void);
typedef void (^IdBlock)(id);
typedef void (^ErrorBlock)(NSError *error);
typedef void (^NumberBlock)(NSNumber *number);
typedef void (^BoolBlock)(BOOL result);
typedef void (^ArrayBlock)(NSArray *array);
typedef void (^DictionaryBlock)(NSDictionary *dictionary);