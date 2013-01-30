//
//  SenTest+Async.m
//  Created by Taras Kalapun on 1/29/13.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import "SenTest+Async.h"

static const char * kSenTestAsyncSemaphore = "kSenTestAsyncSemaphore";

@implementation SenTest (Async)

- (void)setAsyncSemaphore:(dispatch_semaphore_t)semaphore {
    objc_setAssociatedObject(self, kSenTestAsyncSemaphore, (__bridge void *)semaphore, OBJC_ASSOCIATION_ASSIGN);
}

- (dispatch_semaphore_t)asyncSemaphore {
    return objc_getAssociatedObject(self, kSenTestAsyncSemaphore);
}

- (void)blockTestCompleted {
    dispatch_semaphore_signal([self asyncSemaphore]);
}


- (void)runTestWithBlock:(void (^)(void))block {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self setAsyncSemaphore:semaphore];
    
    block();
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    
    //dispatch_release(self.semaphore);
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

- (void)asyncFailWithException:(NSException *)anException;
{
    if ([self asyncSemaphore] == nil) {
        if (anException != nil) {
            [self performSelector:@selector(syncFailWithException:) withObject:anException];
        }
    } else {
        [self blockTestCompleted];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (anException != nil) {
                [self performSelector:@selector(syncFailWithException:) withObject:anException];
            }
        });
    }
}


@end

