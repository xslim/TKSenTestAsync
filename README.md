TKSenTestAsync
==============

SenTest category with Asynchronous support

![](http://cocoapod-badges.herokuapp.com/v/TKSenTestAsync/badge.png)

## Installation

* Using `cocoapods`

``` ruby
  pod 'TKSenTestAsync'
 ```

## Usage

``` objc

#import "SenTest+Async.h"


- (void)testGetObjects {
    [self runTestWithBlock:^{
        doSomeStuff();
        STAssertNil(nil, @"Should be nil");
        [self blockTestCompleted]; // required
    }];
}

```
