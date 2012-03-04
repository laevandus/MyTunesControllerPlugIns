//
//  NSString+NumericCharacterReference.m
//  LyricsFetcher
//
//  Created by Toomas Vahter on 31.12.11.
//  Copyright (c) 2011 Toomas Vahter. All rights reserved.
//

#import "NSString+NumericCharacterReference.h"

@implementation NSString (NumericCharacterReference)

- (NSString *)stringByDecodingNumericCharacterReference
{
	// &#73;
	// [NSString stringWithFormat:@"%c", 73]
	
	NSMutableString *decodedString = [NSMutableString string];
	NSArray *components = [self componentsSeparatedByString:@"&#"];
	NSString *component = nil;
	NSRange semicolonRange = NSMakeRange(NSNotFound, 0);
	NSString *numberReference = nil;
	
	for (component in components) 
	{		
		semicolonRange = [component rangeOfString:@";"];
		
		if (semicolonRange.location != NSNotFound) 
		{
			numberReference = [component substringToIndex:semicolonRange.location];
			
			[decodedString appendFormat:@"%c", [numberReference integerValue]];
			
			if (NSMaxRange(semicolonRange) < [component length]) 
			{
				// In case normal text appends encoded text.
				[decodedString appendString:[component substringFromIndex:NSMaxRange(semicolonRange)]];
			}
		}
	}
	
	return decodedString;
}

@end
