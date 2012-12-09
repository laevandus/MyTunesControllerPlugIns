//
//  Lyrics.m
//  Lyrics
//
//  Created by Toomas Vahter on 27.11.12.
//  Copyright (c) 2012 Toomas Vahter. All rights reserved.
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

#import "Lyrics.h"
#import "NSMutableString+LyricsFetching.h"

@implementation Lyrics

- (NSString *)name
{
	return @"Lyrics";
}

- (NSString *)lyricsForTrackName:(NSString *)name artist:(NSString *)artist album:(NSString *)album
{
	// Cleaning artist and track name
	NSMutableString *cleanedArtistString = [[NSMutableString alloc] initWithString:[artist lowercaseString]];
	NSMutableString *cleanedNameString = [[NSMutableString alloc] initWithString:[name lowercaseString]];
    
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@" -"];
    NSArray *artistComponents = [cleanedArtistString componentsSeparatedByCharactersInSet:set];
    NSArray *nameComponents = [cleanedNameString componentsSeparatedByCharactersInSet:set];
    
	// Remove unneeded characters and append it to the url
    NSMutableString *subpath = [NSMutableString stringWithString:@"/"];
    set = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    for (NSString *component in nameComponents)
    {
        NSMutableString *cleanedComponent = [NSMutableString stringWithString:component];
        [cleanedComponent deleteCharactersInSet:set];
        [subpath appendFormat:@"%@-", cleanedComponent];
    }
    
    [subpath appendString:@"lyrics-"];
    
    for (NSString *component in artistComponents)
    {
        NSMutableString *cleanedComponent = [NSMutableString stringWithString:component];
        [cleanedComponent deleteCharactersInSet:set];
        
        if ([cleanedComponent length])
            [subpath appendFormat:@"%@-", cleanedComponent];
    }
    
    // Delete last - and append .html
    [subpath deleteCharactersInRange:NSMakeRange([subpath length] - 1, 1)];
    [subpath appendString:@".html"];
    
	// Forming the URL
	NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:@"www.lyrics.com" path:subpath];
    
	//NSLog(@"%@", url);
	
	// Fetch page source
	NSError *error = nil;
	NSString *pageSource = [[NSString alloc] initWithContentsOfURL:url usedEncoding:nil error:&error];
	NSMutableString *fetchedLyrics = nil;
    
    //NSLog(@"%@", pageSource);
    
	if (pageSource)
	{
        NSArray *patterns = @[@"<!-- T_ID: T [[:digit:][:space:]]{6,20} -->", @"<!-- CURRENT LYRIC -->"];
        
        for (NSString *pattern in patterns)
        {
            NSError *error = nil;
            NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
            
            if (!regExp)
            {
                NSLog(@"%s %@", __func__, error);
            }
            
            NSTextCheckingResult *result =  [regExp firstMatchInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
            
            if (result)
            {
                NSRange startRange = result.range;
                
                NSRange endRange = [pageSource rangeOfString:@"---" options:NSCaseInsensitiveSearch range:NSMakeRange(NSMaxRange(startRange), [pageSource length] - NSMaxRange(startRange))];
                
                if (startRange.length > 0 && endRange.length > 0 && NSMaxRange(startRange) < endRange.location)
                {
                    NSRange lyricsRange = NSMakeRange(NSMaxRange(startRange), endRange.location - NSMaxRange(startRange));
                    fetchedLyrics = [[NSMutableString alloc] initWithString:[pageSource substringWithRange:lyricsRange]];
                    
                    while ([fetchedLyrics deleteCharactersFromString:@"<" toString:@">" includingStrings:YES]) {}
                    break;
                }
            }
        }
	}
	else
	{
		NSLog(@"Failed fetching page source at url (%@) with error %@", url, [error localizedDescription]);
	}
    
    if ([fetchedLyrics length])
    {
        NSString *cleanedString = [fetchedLyrics stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return (__bridge NSString *)CFXMLCreateStringByUnescapingEntities(NULL, (__bridge CFStringRef)cleanedString, NULL);
    }
    
    return nil;
}

@end
