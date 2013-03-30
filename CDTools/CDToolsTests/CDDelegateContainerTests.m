//
//  CDDelegateContainerTests.m
//  CDTools
//
//  Created by Arseni Buinitsky on 3/30/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "CDDelegateContainerTests.h"


#import "SenTestCase+CDTools.h"
#import "CDDelegateContainer.h"
#import <OCMock/OCMock.h>



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

+ (NSNotificationCenter *)center {
    static NSNotificationCenter *center = nil;
    if (center == nil) {
        center = [[NSNotificationCenter alloc] init];
    }
    return center;
}

- (id)initWithName:(NSString *)name {
    self = [self init];
    if (self) {
        _name = name;
    }
    return self;
}

- (void)processEvent {
    [[MyNotifyingDelegate center] postNotificationName:[NSString stringWithFormat:@"MND-event-%@", _name] object:self];
}

- (void)processEvent:(NSString *)param {
    [[MyNotifyingDelegate center] postNotificationName:[NSString stringWithFormat:@"MND-event-%@:%@", _name, param] object:self];
}

- (void)processEvent:(NSString *)param1 param:(NSString *)param2 {
    NSString *notification = [NSString stringWithFormat:@"MND-event-%@:%@:%@", _name, param1, param2];
    [[MyNotifyingDelegate center] postNotificationName:notification object:self];
}

- (void)processEvent:(NSString *)param1 param:(NSString *)param2 param:(NSString *)param3 {
    NSString *notification = [NSString stringWithFormat:@"MND-event-%@:%@:%@:%@", _name, param1, param2, param3];
    [[MyNotifyingDelegate center] postNotificationName:notification object:self];
}

- (void)processEvent:(NSString *)param1 param:(NSString *)param2 param:(NSString *)param3 param:(NSString *)param4 {
    NSString *notification = [NSString stringWithFormat:@"MND-event-%@:%@:%@:%@:%@", _name, param1, param2, param3, param4];
    [[MyNotifyingDelegate center] postNotificationName:notification object:self];
}

- (void)dealloc {
    NSString *event = [NSString stringWithFormat:@"MND-dealloc-%@", _name];
    [[MyNotifyingDelegate center] postNotificationName:event object:self];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %@>", NSStringFromClass(self.class), _name];
}

@end



@protocol DummyProtocol <NSObject>

@end




@interface MyNotifyingDelegateWithProto : MyNotifyingDelegate <DummyProtocol>

@end

@implementation MyNotifyingDelegateWithProto


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

- (void)testDeallocation {
    id observerMock = [OCMockObject observerMock];
    
    [[MyNotifyingDelegate center] addMockObserver:observerMock name:@"MND-dealloc-1" object:nil];
    [[MyNotifyingDelegate center] addMockObserver:observerMock name:@"MND-dealloc-2" object:nil];
    [[MyNotifyingDelegate center] addMockObserver:observerMock name:@"MND-dealloc-3" object:nil];
    [[MyNotifyingDelegate center] addMockObserver:observerMock name:@"MND-event-1" object:nil];
    [[MyNotifyingDelegate center] addMockObserver:observerMock name:@"MND-event-2" object:nil];
    [[MyNotifyingDelegate center] addMockObserver:observerMock name:@"MND-event-3" object:nil];
    
    
    MyNotifyingDelegate *delegate1 = [[MyNotifyingDelegate alloc] initWithName:@"1"];
    MyNotifyingDelegate *delegate2 = [[MyNotifyingDelegate alloc] initWithName:@"2"];
    MyNotifyingDelegate *delegate3 = [[MyNotifyingDelegate alloc] initWithName:@"3"];
    
    CDDelegateContainer *container = [[CDDelegateContainer alloc] init];
    [container addDelegate:delegate1];
    [container addDelegate:delegate2];
    [container addDelegate:delegate3];

    [[observerMock expect] notificationWithName:@"MND-event-1" object:[OCMArg any]];
    [[observerMock expect] notificationWithName:@"MND-dealloc-2" object:[OCMArg any]];
    [[observerMock expect] notificationWithName:@"MND-event-3" object:[OCMArg any]];
    
    delegate2 = nil;
    [container send:@selector(processEvent)];
    
    [observerMock verify];
    
    [[observerMock expect] notificationWithName:@"MND-dealloc-3" object:[OCMArg any]];
    delegate3 = nil;
    
    [observerMock verify];
    
    [[MyNotifyingDelegate center] removeObserver:observerMock];
}

- (void)testForwardSelectors {
    id observerMock = [OCMockObject observerMock];
    
    [[MyNotifyingDelegate center] addMockObserver:observerMock name:@"MND-event-!" object:nil];
    [[MyNotifyingDelegate center] addMockObserver:observerMock name:@"MND-event-!:param1" object:nil];
    [[MyNotifyingDelegate center] addMockObserver:observerMock name:@"MND-event-!:param1:param2" object:nil];
    [[MyNotifyingDelegate center] addMockObserver:observerMock name:@"MND-event-!:(null):(null)" object:nil];
    [[MyNotifyingDelegate center] addMockObserver:observerMock name:@"MND-event-!:param1:param2:param3" object:nil];
    [[MyNotifyingDelegate center] addMockObserver:observerMock name:@"MND-event-!:param1:param2:param3:param4" object:nil];
    
    
    MyNotifyingDelegate *delegate = [[MyNotifyingDelegate alloc] initWithName:@"!"];
    CDDelegateContainer *container = [[CDDelegateContainer alloc] init];
    [container addDelegate:delegate];
    
    [[observerMock expect] notificationWithName:@"MND-event-!" object:[OCMArg any]];
    [container send:@selector(processEvent)];
    [observerMock verify];
    
    [[observerMock expect] notificationWithName:@"MND-event-!:param1" object:[OCMArg any]];
    [container send:@selector(processEvent:) withParam:@"param1"];
    [observerMock verify];
    
    [[observerMock expect] notificationWithName:@"MND-event-!:param1:param2" object:[OCMArg any]];
    [container send:@selector(processEvent:param:) withParam1:@"param1" param2:@"param2"];
    [observerMock verify];
    
    [[observerMock expect] notificationWithName:@"MND-event-!:param1:param2:param3" object:[OCMArg any]];
    [container send:@selector(processEvent:param:param:) withParam1:@"param1" param2:@"param2" param3:@"param3"];
    [observerMock verify];
    
    [[observerMock expect] notificationWithName:@"MND-event-!:param1:param2:param3:param4" object:[OCMArg any]];
    [container send:@selector(processEvent:param:param:param:) withParam1:@"param1" param2:@"param2" param3:@"param3" param4:@"param4"];
    [observerMock verify];
    
    [[observerMock expect] notificationWithName:@"MND-event-!:(null):(null)" object:[OCMArg any]];
    [container send:@selector(processEvent:param:) withParam1:nil param2:nil];
    [observerMock verify];
    
    [[MyNotifyingDelegate center] removeObserver:observerMock];
}

- (void)testEnsureProtocol {
    id observerMock = [OCMockObject observerMock];
    
    [[MyNotifyingDelegate center] addMockObserver:observerMock name:@"MND-event-wrong" object:nil];
    [[MyNotifyingDelegate center] addMockObserver:observerMock name:@"MND-event-right" object:nil];
    
    CDDelegateContainer *container = [[CDDelegateContainer alloc] init];
    
    id wrongDelegate = [[MyNotifyingDelegate alloc] initWithName:@"wrong"];
    id rightDelegate = [[MyNotifyingDelegateWithProto alloc] initWithName:@"right"];
    
    [container addDelegate:rightDelegate];
    [container addDelegate:wrongDelegate];
    
    [[observerMock expect] notificationWithName:@"MND-event-wrong" object:wrongDelegate];
    [[observerMock expect] notificationWithName:@"MND-event-right" object:rightDelegate];
    [container send:@selector(processEvent)];
    [observerMock verify];
    
    [container ensureProtocol:@protocol(DummyProtocol)];
    [[observerMock expect] notificationWithName:@"MND-event-right" object:rightDelegate];
    [container send:@selector(processEvent)];
    [observerMock verify];

    [container addDelegate:wrongDelegate];
    [[observerMock expect] notificationWithName:@"MND-event-right" object:rightDelegate];
    [container send:@selector(processEvent)];
    [observerMock verify];
    
    [[MyNotifyingDelegate center] removeObserver:observerMock];
}

@end
