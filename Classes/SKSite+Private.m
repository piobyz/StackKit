//
//  SKSite+Private.m
//  StackKit
//
//  Created by Dave DeLong on 1/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SKSite+Private.h"
#import "JSON.h"
#import "SKConstants.h"
#import "SKFunctions.h"

NSLock * fetchLock = nil;

@implementation SKSite (Private)

+ (void) initialize {
	if (self == [SKSite class]) {
		fetchLock = [[NSLock alloc] init];
	}
}

+ (id) allocWithZone:(NSZone *)zone {
	NSLog(@"You may not allocate an SKSite object");
	return nil;
}

#pragma mark -
#pragma mark Init/Dealloc

- (void) mergeInformationFromDictionary:(NSDictionary *)dictionary {
	name = [[dictionary objectForKey:@"name"] retain];
	logoURL = [[NSURL alloc] initWithString:[dictionary objectForKey:@"logo_url"]];
	
	NSString * apiPath = [dictionary objectForKey:@"api_endpoint"];
	apiURL = [[NSURL alloc] initWithString:[apiPath stringByAppendingFormat:@"/%@", SKAPIVersion]];
	
	siteURL = [[NSURL alloc] initWithString:[dictionary objectForKey:@"site_url"]];
	summary = [[dictionary objectForKey:@"description"] retain];
	iconURL = [[NSURL alloc] initWithString:[dictionary objectForKey:@"icon_url"]];
	aliases = [[NSMutableArray alloc] init];
	NSArray * potentialAliases = [dictionary objectForKey:@"aliases"];
	for (NSString * alias in potentialAliases) {
		[aliases addObject:[NSURL URLWithString:alias]];
	}
	NSDictionary *stylingInfo = [dictionary objectForKey:@"styling"];
	linkColor = [SKColorFromHexString([stylingInfo objectForKey:@"link_color"]) retain];
	tagBackgroundColor = [SKColorFromHexString([stylingInfo objectForKey:@"tag_background_color"]) retain];
	tagForegroundColor = [SKColorFromHexString([stylingInfo objectForKey:@"tag_foreground_color"]) retain];
	
	state = SKSiteStateNormal;
	NSString * stateString = [dictionary objectForKey:@"state"];
	if ([stateString isEqual:@"linked_meta"]) {
		state = SKSiteStateLinkedMeta;
	} else if ([stateString isEqual:@"open_beta"]) {
		state = SKSiteStateOpenBeta;
	} else if ([stateString isEqual:@"closed_beta"]) {
		state = SKSiteStateClosedBeta;
	}
	
	timeoutInterval = 60.0;
	requestQueue = [[NSOperationQueue alloc] init];
	[requestQueue setMaxConcurrentOperationCount:1];
	cache = [[NSMutableDictionary alloc] init];
}

- (void) dealloc {
	[apiKey release];
	[name release];
	[logoURL release];
	[apiURL release];
	[siteURL release];
	[summary release];
	[iconURL release];
	[aliases release];
	
	[linkColor release];
	[tagForegroundColor release];
	[tagBackgroundColor release];
	
	[requestQueue cancelAllOperations];
	[requestQueue release];
	
	[managedObjectModel release];
	[persistentStoreCoordinator release];
	[managedObjectContext release];
	[cache release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Locks

+ (NSLock*) fetchLock
{
    return fetchLock;
}

@end
