//
//  AZLyrics.m
//  AZLyrcis
//
//  Created by Toomas Vahter on 26.12.11.
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


#import "AZLyrics.h"
#import "NSMutableString+LyricsFetching.h"

@implementation AZLyrics


- (NSString *)name
{
	return @"AZLyrics";
}


- (NSString *)lyricsForTrackName:(NSString *)name artist:(NSString *)artist album:(NSString *)album
{
	// Cleaning artist and track name
	NSMutableString *cleanedArtistString = [[NSMutableString alloc] initWithString:[artist lowercaseString]];
	NSMutableString *cleanedNameString = [[NSMutableString alloc] initWithString:[name lowercaseString]];
	
	if ([cleanedArtistString hasPrefix:@"the "]) 
	{
		[cleanedArtistString deleteCharactersInRange:NSMakeRange(0, 4)];
	}
	
	// Remove unneeded characters
	NSCharacterSet *set = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
	[cleanedArtistString deleteCharactersInSet:set];
	[cleanedNameString deleteCharactersInSet:set];
	
	// Forming the URL
	NSString *subpath = [NSString stringWithFormat:@"/lyrics/%@/%@.html", cleanedArtistString, cleanedNameString];
	NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:@"www.azlyrics.com" path:subpath];
	
	//NSLog(@"%@", url);
	
	// Remove whitespaces
	NSString *cleanedURLString = [[url absoluteString] stringByReplacingOccurrencesOfString:@"%20" withString:@""];
	url = [[NSURL alloc] initWithString:cleanedURLString];
	
	// Fetch page source
	NSError *error = nil;
	NSString *pageSource = [[NSString alloc] initWithContentsOfURL:url usedEncoding:nil error:&error];
	NSMutableString *fetchedLyrics = nil;
	
	if (pageSource) 
	{
		NSRange startRange = [pageSource rangeOfString:@"<!-- start of lyrics -->"];
		NSRange endRange = [pageSource rangeOfString:@"<!-- end of lyrics -->"];
		
		if (startRange.length > 0 && endRange.length > 0 && NSMaxRange(startRange) < endRange.location) 
		{
			NSRange lyricsRange = NSMakeRange(NSMaxRange(startRange), endRange.location - NSMaxRange(startRange));
			fetchedLyrics = [[NSMutableString alloc] initWithString:[pageSource substringWithRange:lyricsRange]];
			
            while ([fetchedLyrics deleteCharactersFromString:@"<" toString:@">" includingStrings:YES])
            {}
		}
	}
	else 
	{
		NSLog(@"Failed fetching page source at url (%@) with error %@", url, [error localizedDescription]);
	}
		
	return [fetchedLyrics stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
