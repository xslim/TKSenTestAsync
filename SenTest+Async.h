//
//  SenTest+Async.h
//  Created by Taras Kalapun on 1/29/13.
//

#import <SenTestingKit/SenTestingKit.h>

@interface SenTest (Async)

- (void)runTestWithBlock:(void (^)(void))block;
- (void)blockTestCompleted;

@end
