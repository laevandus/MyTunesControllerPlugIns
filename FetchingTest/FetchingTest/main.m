//
//  main.m
//  FetchingTest
//
//  Created by Toomas Vahter on 04.03.12.
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


#import <Foundation/Foundation.h>
#import "iTunes.h"
#import "LyricsFetching.h"
#import "AZLyrics.h"
#import "MetroLyrics.h"
#import "PLyrics.h"


int main(int argc, const char * argv[])
{

	@autoreleasepool 
	{
	    // This is a helper application for testing plug-ins.
		iTunesApplication *iTunes = (iTunesApplication *)[SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
		
		if (!iTunes) 
		{
			NSLog(@"Unable to connect to iTunes");
			return -1;
		}
		
		// For testing use playlist called 'FetchTest'
		__block iTunesPlaylist *fetchTestPlaylist = nil;
		__block BOOL isPlaylistFound = NO;
		
		[[iTunes sources] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) 
		{
			[[obj playlists] enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop)
			 {
				 if ([[object name] isEqualToString:@"FetchTest"]) 
				 {
					 fetchTestPlaylist = object;
					 isPlaylistFound = YES;
					 *stop = YES;
				 }
			 }];
			
			*stop = isPlaylistFound;
		}];
		
		if (!fetchTestPlaylist) 
		{
			NSLog(@"Unable to find playlist called FetchTest");
			return -2;
		}
		
		// Initiate lyrics fetching instances
		NSArray *plugIns = [NSArray arrayWithObjects:
							[[AZLyrics alloc] init],
							[[MetroLyrics alloc] init],
							[[PLyrics alloc] init], 
							nil];
		
		// Fetch lyrics
		iTunesTrack *track = nil;
		NSString *lyrics = nil;
		id plugIn = nil;
		
		for (track in [fetchTestPlaylist tracks]) 
		{
			NSLog(@"*** %@ - %@ ***", track.artist, track.name);
			
			for (plugIn in plugIns) 
			{
				NSLog(@"Fetching using %@…", [plugIn name]);
				
				lyrics = [(id<LyricsFetching>)plugIn lyricsForTrackName:[track name] artist:[track artist] album:[track artist]];
				usleep(1000000);

				if ([lyrics length] > 0) 
				{
					NSLog(@"… found lyrics with length %ld", [lyrics length]);
					NSLog(@"\n%@", lyrics);
					break;
				}
				else 
				{
					NSLog(@"… lyrics not found.");
				}
			}
		}
		
		NSLog(@"Fetching finished");
	}
	
    return 0;
}

