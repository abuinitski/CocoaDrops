//
//  CDOrderedMutableDictionary.m
//  CDTools
//
//  Created by Arseni Buinitsky on 4/20/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "CDOrderedMutableDictionary.h"

@implementation CDOrderedMutableDictionary {
    NSMutableDictionary *_dictionary;
    NSMutableArray *_keys;
}

- (id)init {
    self = [super init];
    if (self) {
        _dictionary = [NSMutableDictionary dictionary];
        _keys = [NSMutableArray array];
    }
    return self;
}

- (id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    self = [super init];
    if (self) {
        _dictionary = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
        _keys = [NSMutableArray arrayWithArray:keys];
    }
    return self;
}

- (id)initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self) {
        _dictionary = [NSMutableDictionary dictionaryWithCapacity:capacity];
        _keys = [NSMutableArray arrayWithCapacity:capacity];
    }
    return self;
}

- (NSUInteger)count {
    return [_keys count];
}

- (id)objectForKey:(id)key {
    return [_dictionary objectForKey:key];
}

- (NSEnumerator *)keyEnumerator {
    return [_keys objectEnumerator];
}

- (void)setObject:(id)object forKey:(id <NSCopying>)key {
    NSUInteger index = [_keys indexOfObject:key];
    if (index == NSNotFound) {
        [_keys addObject:key];
    }
    [_dictionary setObject:object forKey:key];
}

- (void)removeObjectForKey:(id)key {
    [_dictionary removeObjectForKey:key];
    [_keys removeObject:key];
}

@end
