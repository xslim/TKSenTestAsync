//
//  SenTest+Async.m
//  Created by Taras Kalapun on 1/29/13.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import "SenTest+Async.h"

static const NSTimeInterval kDefaultTimeOut = 2.0;
static const char * kSenTestAsyncSemaphore = "kSenTestAsyncSemaphore";

@implementation SenTest (Async)

- (void)setAsyncSemaphore:(dispatch_semaphore_t)semaphore {
    objc_setAssociatedObject(self, kSenTestAsyncSemaphore, (__bridge id)(semaphore), OBJC_ASSOCIATION_ASSIGN);
}

- (dispatch_semaphore_t)asyncSemaphore {
    return (__bridge dispatch_semaphore_t)(objc_getAssociatedObject(self, kSenTestAsyncSemaphore));
}

- (void)blockTestCompleted {
    dispatch_semaphore_signal([self asyncSemaphore]);
}

- (void)runTestWithBlock:(void (^)(void))block {
    [self runTestWithBlock:block timeOut:kDefaultTimeOut];
}

- (void)runTestWithBlock:(void (^)(void))block timeOut:(NSTimeInterval)timeoutInterval {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self setAsyncSemaphore:semaphore];
    
    block();
    
    NSDate *timeoutDate = nil;
    if (timeoutInterval == 0) {
        timeoutDate = [NSDate distantFuture];
    } else {
        timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutInterval];
    }
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        
        if ([(NSDate *)[NSDate date] compare:timeoutDate] == NSOrderedDescending) {
            // Will signal semaphore
            NSException *exception = [NSException exceptionWithName:@"SenTestAsync timeout" reason:@"Operation timed out" userInfo:nil];
            [(SenTestCase *)self asyncFailWithException:exception];
        }
    }
}

@end


@implementation SenTestCase (Async)

+ (void)load;
{
    Method oldMethod = class_getInstanceMethod([self class], @selector(failWithException:));
    if (oldMethod) {
        class_addMethod(objc_getClass(class_getName(self)),
                        @selector(syncFailWithException:),
                        method_getImplementation(oldMethod),
                        method_getTypeEncoding(oldMethod));
    }
    
    Method newMethod = class_getInstanceMethod([self class], @selector(asyncFailWithException:));
    if (newMethod) {
        class_replaceMethod(objc_getClass(class_getName(self)),
                            @selector(failWithException:),
                            method_getImplementation(newMethod),
                            method_getTypeEncoding(newMethod));
    }
}

- (void)asyncFailWithException:(NSException *)anException
{
    if ([self asyncSemaphore] != nil) {
        [self blockTestCompleted];
    }

    if (anException != nil) {
        [self performSelectorOnMainThread:@selector(syncFailWithException:) withObject:anException waitUntilDone:YES];
    }
}


@end

