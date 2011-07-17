/*
 * Copyright 2011 Ziminji
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "NSString+ZIMString.h"

@implementation NSString (ZIMString)

+ (NSString *) capitalizeFirstCharacterInString: (NSString *)string {
	return [string stringByReplacingCharactersInRange: NSMakeRange(0, 1) withString: [[string substringToIndex: 1] uppercaseString]];
}

+ (NSString *) firstTokenInString: (NSString *)string scanUpToCharactersFromSet: (NSCharacterSet *)stopSet {
	NSScanner *scanner = [NSScanner scannerWithString: string];
	NSString *buffer;
	if (![scanner scanUpToCharactersFromSet: stopSet intoString: &buffer]) {
		return @"";
	}
	return buffer;
}

@end
