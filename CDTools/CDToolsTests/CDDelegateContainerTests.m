//
//  CDDelegateContainerTests.m
//  CDTools
//
//  Created by Arseni Buinitsky on 3/30/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "CDDelegateContainerTests.h"

#import <OCMock/OCMock.h>

#import "SenTestCase+CDTools.h"
#import "CDDelegateContainer.h"



@interface MySimpleDelegate : NSObject

- (void)processEvent;

- (void)processEvent:(NSNumber *)number;

- (void)processEvent:(NSString *)string number:(NSNumber *)number;

@end


@implementation MySimpleDelegate {
    NSString *_name;
}

- (id)initWithName:(NSString *)name {
    self = [self init];
    if (self) {
        _name = name;
    }
    return self;
}

- (void)processEvent {
    NSLog(@"MSD %@: processEvent", _name);
}

- (void)processEvent:(NSNumber *)number {
    NSLog(@"MSD %@: processEvent:%@(%@)", _name, NSStringFromClass(number.class), number);
}

- (void)processEvent:(NSString *)string number:(NSNumber *)number {
    NSLog(@"MSD %@: processEvent:%@(%@) number:%@(%@)", _name, NSStringFromClass(string.class), string, NSStringFromClass(number.class), number);
}

- (void)dealloc {
    NSLog(@"MSD %@: dealloc", _name);
}

@end




@interface MyNotifyingDelegate : NSObject

- (void)processEvent;

@end


@implementation MyNotifyingDelegate {
    NSString *_name;
}

- (id)initWithName:(NSString *)name {
    self = [self init];
    if (self) {
        _name = name;
    }
    return self;
}

- (void)processEvent {
    NSLog(@"event %@", _name);
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"MND-event-%@", _name] object:nil];
}

- (void)dealloc {
    NSLog(@"dealloc %@", _name);
    NSString *event = [NSString stringWithFormat:@"MND-dealloc-1"];
    [[NSNotificationCenter defaultCenter] postNotificationName:event object:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %@>", NSStringFromClass(self.class), _name];
}

@end




@implementation CDDelegateContainerTests

- (void)testBasic {
    id delegate1 = [OCMockObject mockForClass:[MySimpleDelegate class]];
    [[delegate1 expect] processEvent];
    
    id delegate2 = [OCMockObject mockForClass:[MySimpleDelegate class]];
    [[delegate2 expect] processEvent];
    
    id delegate3 = [OCMockObject mockForClass:[MySimpleDelegate class]];
    [[delegate3 expect] processEvent];
    
    CDDelegateContainer *container = [[CDDelegateContainer alloc] init];
    [container addDelegate:delegate1];
    [container addDelegate:delegate2];
    [container addDelegate:delegate3];
    [container send:@selector(processEvent)];
    
    [delegate1 verify];
    [delegate2 verify];
    [delegate3 verify];
    
    [[delegate1 expect] processEvent];
    [[delegate3 expect] processEvent];
    [container removeDelegate:delegate2];
    [container send:@selector(processEvent)];
    
    [delegate1 verify];
    [delegate2 verify];
    [delegate3 verify];
}

- (void)testNotification {
    id nm = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:nm name:@"MND-dealloc-1" object:nil];
    
    [[nm expect] notificationWithName:@"MND-dealloc-1" object:[OCMArg any]];

    MyNotifyingDelegate *delegate1 = [[MyNotifyingDelegate alloc] initWithName:@"1"];
    delegate1 = nil;
//     [[NSNotificationCenter defaultCenter] postNotificationName:@"MND-dealloc-1" object:nil];
    
    [nm verify];
}

- (void)testDeallocation {
//    id observerMock = [OCMockObject observerMock];
//    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:@"MND-dealloc-1" object:nil];
//    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:@"MND-dealloc-2" object:nil];
//    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:@"MND-dealloc-3" object:nil];
//    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:@"MND-event-1" object:nil];
//    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:@"MND-event-2" object:nil];
//    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:@"MND-event-3" object:nil];
    
    
//    MyNotifyingDelegate *delegate1 = [[MyNotifyingDelegate alloc] initWithName:@"1"];
//    MyNotifyingDelegate *delegate2 = [[MyNotifyingDelegate alloc] initWithName:@"2"];
//    MyNotifyingDelegate *delegate3 = [[MyNotifyingDelegate alloc] initWithName:@"3"];
//    
//    CDDelegateContainer *container = [[CDDelegateContainer alloc] init];
//    [container addDelegate:delegate1];
//    [container addDelegate:delegate2];
//    [container addDelegate:delegate3];
    
//    NSLog(@"will expect");

//    [[observerMock expect] notificationWithName:@"MND-event-1" object:[OCMArg any]];
//    [[observerMock expect] notificationWithName:@"MND-dealloc-2" object:[OCMArg any]];
//    [[observerMock expect] notificationWithName:@"MND-event-3" object:[OCMArg any]];
    
//    delegate2 = nil;
//    [container send:@selector(processEvent)];
//    
//    [observerMock verify];
}

@end
