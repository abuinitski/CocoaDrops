//
// Created by Arseni Buinitsky
//

#import <Foundation/Foundation.h>

#import "CDBasicBlocks.h"

/**
* Simple container for handling weak references to a number of delegates.
* Supports graceful handling of deallocated delegates, so no need to explicitly unsubscribe if you don't need to.
*/
@interface CDDelegateContainer : NSObject

- (void)forEach:(IdBlock)block;

- (void)ensureProtocol:(Protocol *)protocol;

- (void)send:(SEL)selector;
- (void)send:(SEL)selector withParam:(id)object;
- (void)send:(SEL)selector withParam1:(id)param1 param2:(id)param2;
- (void)send:(SEL)selector withParam1:(id)param1 param2:(id)param2 param3:(id)param3;
- (void)send:(SEL)selector withParam1:(id)param1 param2:(id)param2 param3:(id)param3 param4:(id)param4;

- (void)addDelegate:(id)delegate;
- (BOOL)removeDelegate:(id)delegate;

@end