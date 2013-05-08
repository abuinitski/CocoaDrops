//
// Created by Arseni Buinitsky
//

#import "CDDelegateContainer.h"
#import "CDLog.h"
#import "NSArray+CocoaDrops.h"

#import <objc/message.h>


@interface CDDelegateHandle : NSObject

+ (id)newWithDelegate:(id)delegate;

@property (nonatomic, weak) id delegate;

@end


@implementation CDDelegateHandle

+ (id)newWithDelegate:(id)delegate {
    CDDelegateHandle *handle = [[CDDelegateHandle alloc] init];
    handle.delegate = delegate;
    return handle;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![[other class] isEqual:[self class]]) {
        return NO;
    }
    return self.delegate == [other delegate];
}

@end


@implementation CDDelegateContainer {
@private
    NSMutableArray *delegates;
    NSMutableArray *protocols;
}

- (id)init {
    self = [super init];
    if (self) {
        delegates = [[NSMutableArray alloc] init];
        protocols = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)forEach:(IdBlock)block {
    @autoreleasepool {
        for (NSUInteger index = 0; index < delegates.count; ) {
            CDDelegateHandle *handle = [delegates objectAtIndex:index];
            if (handle.delegate) {
                block(handle.delegate);
                ++index;
            } else {
                [delegates removeObjectAtIndex:index];
            }
        }
    }
}

- (void)addDelegate:(id)delegate {
    if (delegate) {
        __block BOOL pass = YES;
        
        [protocols enumerateObjectsUsingBlock:^ (Protocol *protocol, NSUInteger index, BOOL *stop) {
            if (![delegate conformsToProtocol:protocol]) {
                CDLog(@"[WARN] CDDelegateContainer: ensureProtocol check failed: delegate %@ does not conform to %@", delegate, NSStringFromProtocol(protocol));
                pass = NO;
                *stop = YES;
            }
        }];
        
        if (pass) {
            [delegates addObject:[CDDelegateHandle newWithDelegate:delegate]];
        }
    }
}

- (BOOL)removeDelegate:(id)delegate {
    BOOL didRemove = NO;

    if (delegate) {
        for (NSUInteger index = 0; index < delegates.count; ) {
            CDDelegateHandle *handle = [delegates objectAtIndex:index];
            if (handle.delegate == nil) {
                [delegates removeObjectAtIndex:index];
            } else if (handle.delegate == delegate) {
                [delegates removeObjectAtIndex:index];
                didRemove = YES;
            } else {
                ++index;
            }
        }
    }

    return didRemove;
}

- (void)ensureProtocol:(Protocol *)protocol {
    if (protocol) {
        [protocols addObject:protocol];
        
        NSMutableArray *toRemove = [NSMutableArray array];
        [self forEach:^ (id delegate) {
            if (![delegate conformsToProtocol:protocol]) {
                CDLog(@"[WARN] CDDelegateContainer: ensureProtocol check failed: delegate %@ does not conform to %@", delegate, NSStringFromProtocol(protocol));
                [toRemove addObject:delegate];
            }
        }];
        
        [toRemove forEach:^ (id delegate) {
            [self removeDelegate:delegate];
        }];
    }
}

- (void)send:(SEL)selector {
    [self forEach:^ (id delegate) {
        if ([delegate respondsToSelector:selector]) {
            objc_msgSend(delegate, selector);
        }
    }];
}

- (void)send:(SEL)selector withParam:(id)object {
    [self forEach:^ (id delegate) {
        if ([delegate respondsToSelector:selector]) {
            objc_msgSend(delegate, selector, object);
        }
    }];
}

- (void)send:(SEL)selector withParam1:(id)param1 param2:(id)param2 {
    [self forEach:^ (id delegate) {
        if ([delegate respondsToSelector:selector]) {
            objc_msgSend(delegate, selector, param1, param2);
        }
    }];
}

- (void)send:(SEL)selector withParam1:(id)param1 param2:(id)param2 param3:(id)param3 {
    [self forEach:^ (id delegate) {
        if ([delegate respondsToSelector:selector]) {
            objc_msgSend(delegate, selector, param1, param2, param3);
        }
    }];
}

- (void)send:(SEL)selector withParam1:(id)param1 param2:(id)param2 param3:(id)param3 param4:(id)param4 {
    [self forEach:^ (id delegate) {
        if ([delegate respondsToSelector:selector]) {
            objc_msgSend(delegate, selector, param1, param2, param3, param4);
        }
    }];
}

@end