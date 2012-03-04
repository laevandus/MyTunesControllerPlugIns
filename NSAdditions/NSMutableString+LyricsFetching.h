//
//  NSMutableString+LyricsFetching.h
//  PLyrics
//
//  Created by Toomas Vahter on 30.12.11.
//  Copyright (c) 2011 Toomas Vahter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (LyricsFetching)

- (void)deleteCharactersFromRangeOfString:(NSString *)startString toRangeOfString:(NSString *)endString;
- (void)deleteCharactersToMaximumRangeOfString:(NSString *)searchString;
- (void)deleteCharactersFromMaximumRangeOfString:(NSString *)searchString;

- (void)deleteCharactersInSet:(NSCharacterSet *)set;

@end
