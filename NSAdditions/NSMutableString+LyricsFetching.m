//
//  NSMutableString+LyricsFetching.m
//  PLyrics
//
//  Created by Toomas Vahter on 30.12.11.
//  Copyright (c) 2011 Toomas Vahter. All rights reserved.
//

#import "NSMutableString+LyricsFetching.h"

@implementation NSMutableString (LyricsFetching)

- (void)deleteCharactersFromRangeOfString:(NSString *)startString toRangeOfString:(NSString *)endString
{
	NSRange startRange = [self rangeOfString:startString options:NSCaseInsensitiveSearch];
	
	if (startRange.location == NSNotFound)
		return;
	
	NSRange endRange = [self rangeOfString:endString options:NSCaseInsensitiveSearch range:NSMakeRange(NSMaxRange(startRange), [self length] - NSMaxRange(startRange))];
	
	if (startRange.length > 0 && endRange.length > 0 && NSMaxRange(startRange) < endRange.location) 
	{
		NSRange deleteRange = NSMakeRange(startRange.location, NSMaxRange(endRange) - startRange.location);
		[self deleteCharactersInRange:deleteRange];
	}
}


- (void)deleteCharactersToMaximumRangeOfString:(NSString *)searchString
{
	NSRange range = [self rangeOfString:searchString options:NSCaseInsensitiveSearch];
	
	if (range.location != NSNotFound) 
	{
		[self deleteCharactersInRange:NSMakeRange(0, NSMaxRange(range))];
	}
}


- (void)deleteCharactersFromMaximumRangeOfString:(NSString *)searchString
{
	NSRange range = [self rangeOfString:searchString options:NSCaseInsensitiveSearch];

	if (range.location != NSNotFound) 
	{
		[self deleteCharactersInRange:NSMakeRange(NSMaxRange(range), [self length] - NSMaxRange(range))];
	}
}


- (void)deleteCharactersInSet:(NSCharacterSet *)set
{
	NSRange range = [self rangeOfCharacterFromSet:set options:NSCaseInsensitiveSearch];
	
	while (range.location != NSNotFound) 
	{
		[self deleteCharactersInRange:range];
		
		range = [self rangeOfCharacterFromSet:set options:NSCaseInsensitiveSearch];
	}
}

@end
