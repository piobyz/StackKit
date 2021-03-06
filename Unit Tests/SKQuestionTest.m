//
//  SKQuestionTest.m
//  StackKit
/**
  Copyright (c) 2011 Dave DeLong
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 **/

#import "SKQuestionTest.h"
#import "SKTestConstants.h"
#import <StackKit/StackKit.h>

@implementation SKQuestionTest

- (void) setUp {
	didReceiveCallback = NO;
}

- (void) tearDown {
	didReceiveCallback = NO;
}

- (void) testSingleQuestion {
	SKSite * site = [SKSite stackOverflowSite];
	
	SKFetchRequest * r = [[SKFetchRequest alloc] init];
	[r setEntity:[SKQuestion class]];
	[r setPredicate:[NSPredicate predicateWithFormat:@"%K = %d", SKQuestionID, 1283419]];
	
	NSError * e = nil;
	NSArray * matches = [site executeSynchronousFetchRequest:r error:&e];
	[r release];
	
	STAssertTrue([matches count] > 0, @"Expecting 1 question");
	STAssertNil(e, @"Expecting nil error: %@", e);
	
	SKQuestion * q = [matches objectAtIndex:0];
	
	STAssertEqualObjects([q title], @"Valid use of accessors in init and dealloc methods?", @"Unexpected title");
	STAssertTrue([[q score] intValue] == 7, @"Unexpected vote count");
	STAssertTrue([[q viewCount] intValue] > 0, @"Unexpected view count");
	STAssertTrue([[q favoriteCount] intValue] > 0, @"Unexpected favorited count");
	STAssertTrue([[q upVotes] intValue] == 7, @"Unexpected upvote count");
	STAssertTrue([[q downVotes] intValue] == 0, @"Unexpected downvote count");
	STAssertNotNil([q body], @"question body shouldn't be nil");
	
	NSSet * expectedTagNames = [NSSet setWithObjects:@"objective-c",@"properties",@"accessors",@"initialization",@"dealloc", nil];
	NSSet * actualTagNames = [NSSet setWithArray:[[q tags] valueForKey:SKTagName]];
	STAssertEqualObjects(expectedTagNames, actualTagNames, @"unexpected tags.  Expected %@, given %@", expectedTagNames, actualTagNames);
}

- (void) testMultipleQuestions {
	SKSite * site = [SKSite stackOverflowSite];
	
	NSDictionary* mockUpQuestionDict = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithInt:1283419],SKQuestionID,
										@"http://www.example.com",SKQuestionTimelineURL,
										@"http://www.example.com",SKQuestionCommentsURL,
										@"http://www.example.com",SKQuestionAnswersURL,										
										nil];
	
	SKQuestion* testQuestion = [[SKQuestion alloc] initWithSite:site dictionaryRepresentation:mockUpQuestionDict];
	
	NSArray* questionsToFetch = [NSArray arrayWithObjects:
								 @"4729906",
								 [NSNumber numberWithInt:3389487],
								 testQuestion,
								 nil];
	
	SKFetchRequest * r = [[SKFetchRequest alloc] init];
	[r setEntity:[SKQuestion class]];
	[r setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", SKQuestionID, questionsToFetch]];
	
	NSError * e = nil;
	NSArray * matches = [site executeSynchronousFetchRequest:r error:&e];
	[r release];
	
	STAssertTrue([matches count] == 3, @"Expecting 3 questions");
	STAssertNil(e, @"Expecting nil error: %@", e);
	
	SKQuestion * q = [matches objectAtIndex:0];
	STAssertTrue([[q questionID] isEqualToNumber:[NSNumber numberWithInt:4729906]], @"Unexpected question returned at index 0");
	
	q = [matches objectAtIndex:1];
	STAssertTrue([[q questionID] isEqualToNumber:[NSNumber numberWithInt:3389487]], @"Unexpected question returned at index 1");
	
	q = [matches objectAtIndex:2];
	STAssertEqualObjects([q title], @"Valid use of accessors in init and dealloc methods?", @"Unexpected title");
	STAssertTrue([[q score] intValue] == 7, @"Unexpected vote count");
	STAssertTrue([[q viewCount] intValue] > 0, @"Unexpected view count");
	STAssertTrue([[q favoriteCount] intValue] > 0, @"Unexpected favorited count");
	STAssertTrue([[q upVotes] intValue] == 7, @"Unexpected upvote count");
	STAssertTrue([[q downVotes] intValue] == 0, @"Unexpected downvote count");
	STAssertNotNil([q body], @"question body shouldn't be nil");
	
	NSSet * expectedTagNames = [NSSet setWithObjects:@"objective-c",@"properties",@"accessors",@"initialization",@"dealloc", nil];
	NSSet * actualTagNames = [NSSet setWithArray:[[q tags] valueForKey:SKTagName]];
	STAssertEqualObjects(expectedTagNames, actualTagNames, @"unexpected tags.  Expected %@, given %@", expectedTagNames, actualTagNames);
}

- (void) testTaggedQuestions {
	SKSite * s = [SKSite stackOverflowSite];
	
	SKFetchRequest * r = [[SKFetchRequest alloc] init];
	[r setEntity:[SKQuestion class]];
	[r setPredicate:[NSPredicate predicateWithFormat:@"%K CONTAINS %@", SKQuestionTags, @"cocoa"]];
	
	NSError * e = nil;
	NSArray * results = [s executeSynchronousFetchRequest:r error:&e];
	[r release];
	
	for (SKQuestion * q in results) {
		NSSet * questionTags = [[q tags] valueForKey:SKTagName];
		STAssertTrue([questionTags containsObject:@"cocoa"], @"Question (%@) is not tagged with \"cocoa\": %@", q, [q tags]);
	}
}

- (void) testQuestionSearch {
	SKSite * s = [SKSite stackOverflowSite];
	
	SKFetchRequest * r = [[SKFetchRequest alloc] init];
	[r setEntity:[SKQuestion class]];
	[r setPredicate:[NSPredicate predicateWithFormat:@"%K CONTAINS %@", SKQuestionTitle, @"Constants by another name"]];
	
	NSError * e = nil;
	NSArray * results = [s executeSynchronousFetchRequest:r error:&e];
	[r release];
	
	STAssertNil(e, @"Error should be nil: %@", e);
	STAssertTrue([results count] > 0, @"expecting at least 1 result");
	
	SKQuestion * q = [results objectAtIndex:0];
	
	STAssertEqualObjects([q ownerID], [NSNumber numberWithInt:115730], @"Owner should be #115730: %@", [q ownerID]);
}

- (void) testAllQuestions {
	SKSite * s = [SKSite stackOverflowSite];
	
	SKFetchRequest * r = [[SKFetchRequest alloc] init];
	[r setEntity:[SKQuestion class]];
	[r setSortDescriptor:[[[NSSortDescriptor alloc] initWithKey:SKQuestionCreationDate ascending:NO] autorelease]];
	[r setFetchLimit:10];
	
	NSError * e = nil;
	NSArray * results = [s executeSynchronousFetchRequest:r error:&e];
	[r release];
	
	STAssertNil(e, @"Error should be nil: %@", e);
	STAssertTrue([results count] == 10, @"expecting 10 results; got %d", [results count]);
	
	NSDate * previous = [NSDate distantFuture];
	for (SKQuestion * q in results) {
		NSDate * qDate = [q creationDate];
		STAssertTrue([[qDate laterDate:previous] isEqualToDate:previous], @"%@ is earlier than %@", previous, qDate);
		previous = qDate;
	}
}

- (void) testUnansweredTaggedQuestions {
	SKSite * s = [SKSite stackOverflowSite];
	
	SKFetchRequest * r = [[SKFetchRequest alloc] init];
	[r setEntity:[SKQuestion class]];
	[r setPredicate:[NSPredicate predicateWithFormat:@"%K = 0 AND %K CONTAINS (%@)", SKQuestionAnswerCount, SKQuestionTags, @"iphone"]];
	
	NSError * e = nil;
	NSArray * results = [s executeSynchronousFetchRequest:r error:&e];
	[r release];
	
	STAssertNil(e, @"Error should be nil: %@", e);
	
	for (SKQuestion * question in results) {
		STAssertTrue([[question answerCount] intValue] == 0, @"question should have 0 answers.  has: %@", [question answerCount]);
		
		NSArray * tagNames = [[question tags] valueForKey:SKTagName];
		STAssertTrue([tagNames containsObject:@"iphone"], @"questions should have \"iphone\" tag");
	}
}

- (void) testAsynchronousQuestion {
	SKSite * s = [SKSite stackOverflowSite];
	
	SKFetchRequest * r = [[SKFetchRequest alloc] init];
	[r setEntity:[SKQuestion class]];
	[r setPredicate:[NSPredicate predicateWithFormat:@"%K = %d", SKQuestionID, 3145955]];
	[r setDelegate:self];
	[s executeFetchRequest:r];
	
	while (didReceiveCallback == NO) {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	}
	
	STAssertNil([r error], @"Fetch request error should be nil: %@", [r error]);
	
	[r release];
}

- (void)fetchRequest:(SKFetchRequest *)request didFailWithError:(NSError *)error {
	didReceiveCallback = YES;
}

- (void) fetchRequest:(SKFetchRequest *)request didReturnResults:(NSArray *)results {
	didReceiveCallback = YES;
}

@end
