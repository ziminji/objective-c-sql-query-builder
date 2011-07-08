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

#import <CommonCrypto/CommonDigest.h>
#import "ZIMMessageDigest.h"

@implementation ZIMMessageDigest

+ (NSString *) hashStringWithMD5: (NSString *)string {
	const char *cString = [string UTF8String];
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5(cString, strlen(cString), digest);
	NSMutableString *hash = [NSMutableString stringWithCapacity: CC_MD5_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
		[hash appendFormat: @"%02X", digest[i]];
	}
	return [hash lowercaseString];
}

+ (NSString *) hashStringWithSHA1: (NSString *)string {
	const char *cString = [string UTF8String];
	unsigned char digest[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(cString, strlen(cString), digest);
	NSMutableString *hash = [NSMutableString stringWithCapacity: CC_SHA1_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
		[hash appendFormat: @"%02X", digest[i]];
	}
	return [hash lowercaseString];
}

@end
