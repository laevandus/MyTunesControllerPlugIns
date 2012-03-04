//
//  NSString+NumericCharacterReference.h
//  LyricsFetcher
//
//  Created by Toomas Vahter on 31.12.11.
//  Copyright (c) 2011 Toomas Vahter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NumericCharacterReference)

- (NSString *)stringByDecodingNumericCharacterReference;

@end
