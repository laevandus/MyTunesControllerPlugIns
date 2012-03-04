//
//  PLyrics.m
//  PLyrics
//
//  Created by Toomas Vahter on 30.12.11.
//  Copyright (c) 2011 Toomas Vahter. All rights reserved.
//

#import "PLyrics.h"
#import "NSMutableString+LyricsFetching.h"

@implementation PLyrics


- (NSString *)name
{
	return @"PLyrics";
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
	NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:@"www.plyrics.com" path:subpath];
	
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
		NSRange startRange = [pageSource rangeOfString:@"<!-- song body -->"];
		NSRange endRange = [pageSource rangeOfString:@"<!-- end of song body -->"];
		
		if (startRange.length > 0 && endRange.length > 0 && NSMaxRange(startRange) < endRange.location) 
		{
			NSRange lyricsRange = NSMakeRange(NSMaxRange(startRange), endRange.location - NSMaxRange(startRange));
			fetchedLyrics = [[NSMutableString alloc] initWithString:[pageSource substringWithRange:lyricsRange]];
			
			// <!-- AddThis Button BEGIN --> <!-- AddThis Button END -->
			[fetchedLyrics deleteCharactersFromRangeOfString:@"<!-- AddThis Button BEGIN -->" toRangeOfString:@"<!-- AddThis Button END -->"];
			
			// <!-- JANGO PLAYER --> <!-- END OF JANGO PLAYER -->
			[fetchedLyrics deleteCharactersFromRangeOfString:@"<!-- JANGO PLAYER -->" toRangeOfString:@"<!-- END OF JANGO PLAYER -->"];
			
			// Remove <br>
			[fetchedLyrics replaceOccurrencesOfString:@"<br>" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [fetchedLyrics length])];
						
			// Remove italic, headers etc
			NSArray *tags = [[NSArray alloc] initWithObjects:@"div", @"a", @"i", @"b", @"h1", @"h2", @"h3", @"h4", @"h5", nil];
			NSString *tag = nil;
			NSRange tagStartRange = NSMakeRange(NSNotFound, 0);
			NSRange tagEndRange = NSMakeRange(NSNotFound, 0);
			
			for (tag in tags) 
			{
				BOOL tagRemoved = NO;
				
				while (!tagRemoved) 
				{
					tagStartRange = [fetchedLyrics rangeOfString:[NSString stringWithFormat:@"<%@", tag]];
					tagEndRange = [fetchedLyrics rangeOfString:[NSString stringWithFormat:@"</%@>", tag]];
					
					if (tagStartRange.location != NSNotFound && tagEndRange.location != NSNotFound && NSMaxRange(tagStartRange) < tagEndRange.location) 
					{
						[fetchedLyrics deleteCharactersInRange:NSMakeRange(tagStartRange.location, NSMaxRange(tagEndRange) - tagStartRange.location)];
					}
					else 
					{
						tagRemoved = YES;
					}
				}
			}
			
			[fetchedLyrics deleteCharactersFromRangeOfString:@"[" toRangeOfString:@"]"];
		}
	}
	else 
	{
		NSLog(@"Failed fetching page source at url (%@) with error %@", url, [error localizedDescription]);
	}
	
	return [fetchedLyrics stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
