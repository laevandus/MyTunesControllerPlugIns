//
//  NSMutableString+LyricsFetching.m
//  PLyrics
//
//  Created by Toomas Vahter on 30.12.11.
//  Copyright (c) 2011 Toomas Vahter. All rights reserved.
//
//  This content is released under the MIT License (http://www.opensource.org/licenses/mit-license.php).
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


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
