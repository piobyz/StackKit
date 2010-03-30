//
//  SKFetchRequest+Private.h
//  StackKit
//
//  Created by Dave DeLong on 3/29/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKFetchRequest (Private)

- (NSString *) entityDataKey;
- (NSURL *) apiCallWithError:(NSError **)error;
- (NSArray *) executeWithError:(NSError **)error;

@end