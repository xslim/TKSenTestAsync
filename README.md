TKSenTestAsync
==============

SenTest category with Asynchronous support

## Installation

* Using `cocoapods`

``` ruby
  pod 'TKSenTestAsync', :podspec => 'https://raw.github.com/xslim/TKSenTestAsync/master/TKSenTestAsync.podspec'
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
