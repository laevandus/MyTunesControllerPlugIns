//
//  MetroLyrics.m
//  MetroLyrics
//
//  Created by Toomas Vahter on 31.12.11.
//  Copyright (c) 2011 Toomas Vahter. All rights reserved.
//

#import "MetroLyrics.h"
#import "NSMutableString+LyricsFetching.h"
#import "NSString+NumericCharacterReference.h"

@implementation MetroLyrics


- (NSString *)name
{
	return @"MetroLyrics";
}


- (NSString *)lyricsForTrackName:(NSString *)name artist:(NSString *)artist album:(NSString *)album
{
	// Cleaning artist and track name
	NSMutableString *cleanedArtistString = [[NSMutableString alloc] initWithString:[artist lowercaseString]];
	NSMutableString *cleanedNameString = [[NSMutableString alloc] initWithString:[name lowercaseString]];
	
	// TODO: needs better approach
	// Remove unneeded characters
	NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"().,-'"];
	[cleanedArtistString deleteCharactersInSet:set];
	[cleanedNameString deleteCharactersInSet:set];
	
	// Forming the URL
	NSString *subpath = [NSString stringWithFormat:@"/%@-lyrics-%@.html", cleanedNameString, cleanedArtistString];
	subpath = [subpath stringByReplacingOccurrencesOfString:@" " withString:@"-"];
	NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:@"www.metrolyrics.com" path:subpath];
	
	//NSLog(@"%@", url);
	
	// Fetch page source
	NSError *error = nil;
	NSMutableString *pageSource = [[NSMutableString alloc] initWithContentsOfURL:url usedEncoding:nil error:&error];
	NSMutableString *fetchedLyrics = [[NSMutableString alloc] init];
	
	if (pageSource) 
	{
		// Validate lyrics by searching tag: <title>ARTIST - TRACK LYRICS</title>
		NSString *titleContents = [NSString stringWithFormat:@"%@ - %@ LYRICS", [artist uppercaseString], [name uppercaseString]];
		NSMutableString *titleTagContents = [[NSMutableString alloc] initWithString:pageSource];
		[titleTagContents deleteCharactersFromMaximumRangeOfString:@"</title>"];
		[titleTagContents deleteCharactersToMaximumRangeOfString:@"<title>"];
		[titleTagContents replaceOccurrencesOfString:@"</title>" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [titleTagContents length])];
		
		if ([titleTagContents isEqualToString:titleContents]) 
		{
			// Looks like correct lyrics
			[pageSource deleteCharactersToMaximumRangeOfString:@"<div id=\"lyrics-body\">"];
			[pageSource deleteCharactersFromMaximumRangeOfString:@"</div>"];
			
			NSArray *encodedLines = [[pageSource stringByReplacingOccurrencesOfString:@"<br />" withString:@""] componentsSeparatedByString:@"</span>"];
			NSString *encodedLine = nil;
			NSRange searchRange = NSMakeRange(0, 0);
			NSString *cleanedEncodedLine = nil;
			
			for (encodedLine in encodedLines) 
			{
				if ([encodedLine rangeOfString:@"&#"].length > 0) 
				{
					// Valid line. Cut out > … <
					searchRange = [encodedLine rangeOfString:@">"];
					
					if (searchRange.length > 0) 
					{
						cleanedEncodedLine = [encodedLine substringFromIndex:NSMaxRange(searchRange)];
						[fetchedLyrics appendFormat:@"%@\n", [cleanedEncodedLine stringByDecodingNumericCharacterReference]];
					}
				}
			}
			
			// Remove italic, headers etc
			NSArray *tags = [[NSArray alloc] initWithObjects:@"i", @"b", @"h1", @"h2", @"h3", @"h4", @"h5", nil];
			NSString *tag = nil;
			NSRange tagStartRange = NSMakeRange(NSNotFound, 0);
			NSRange tagEndRange = NSMakeRange(NSNotFound, 0);
			
			for (tag in tags) 
			{
				BOOL tagRemoved = NO;
				
				while (!tagRemoved) 
				{
					tagStartRange = [fetchedLyrics rangeOfString:[NSString stringWithFormat:@"<%@>", tag]];
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
			
			// Trimm
			[fetchedLyrics setString:[fetchedLyrics length] ? [fetchedLyrics stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : @""];
		}
	}
	else 
	{
		NSLog(@"Failed fetching page source at url (%@) with error %@", url, [error localizedDescription]);
	}
	
	return [fetchedLyrics length] ? fetchedLyrics : nil;
}

@end
