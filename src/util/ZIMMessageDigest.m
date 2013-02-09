/*
 * Copyright 2011-2013 Ziminji
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

+ (NSString *) md2: (NSString *)string {
	const char *cString = [string UTF8String];
	unsigned char digest[CC_MD2_DIGEST_LENGTH];
	CC_MD2(cString, strlen(cString), digest);
	NSMutableString *hash = [NSMutableString stringWithCapacity: CC_MD2_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_MD2_DIGEST_LENGTH; i++) {
		[hash appendFormat: @"%02x", digest[i]];
	}
	return [hash lowercaseString];
}

+ (NSString *) md4: (NSString *)string {
	const char *cString = [string UTF8String];
	unsigned char digest[CC_MD4_DIGEST_LENGTH];
	CC_MD4(cString, strlen(cString), digest);
	NSMutableString *hash = [NSMutableString stringWithCapacity: CC_MD4_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_MD4_DIGEST_LENGTH; i++) {
		[hash appendFormat: @"%02x", digest[i]];
	}
	return [hash lowercaseString];
}

+ (NSString *) md5: (NSString *)string {
	const char *cString = [string UTF8String];
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5(cString, strlen(cString), digest);
	NSMutableString *hash = [NSMutableString stringWithCapacity: CC_MD5_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
		[hash appendFormat: @"%02x", digest[i]];
	}
	return [hash lowercaseString];
}

+ (NSString *) sha1: (NSString *)string {
	const char *cString = [string UTF8String];
	unsigned char digest[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(cString, strlen(cString), digest);
	NSMutableString *hash = [NSMutableString stringWithCapacity: CC_SHA1_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
		[hash appendFormat: @"%02x", digest[i]];
	}
	return [hash lowercaseString];
}

+ (NSString *) sha224: (NSString *)string {
	const char *cString = [string UTF8String];
	unsigned char digest[CC_SHA224_DIGEST_LENGTH];
	CC_SHA224(cString, strlen(cString), digest);
	NSMutableString *hash = [NSMutableString stringWithCapacity: CC_SHA224_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_SHA224_DIGEST_LENGTH; i++) {
		[hash appendFormat: @"%02x", digest[i]];
	}
	return [hash lowercaseString];
}

+ (NSString *) sha256: (NSString *)string {
	const char *cString = [string UTF8String];
	unsigned char digest[CC_SHA256_DIGEST_LENGTH];
	CC_SHA256(cString, strlen(cString), digest);
	NSMutableString *hash = [NSMutableString stringWithCapacity: CC_SHA256_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
		[hash appendFormat: @"%02x", digest[i]];
	}
	return [hash lowercaseString];
}

+ (NSString *) sha384: (NSString *)string {
	const char *cString = [string UTF8String];
	unsigned char digest[CC_SHA384_DIGEST_LENGTH];
	CC_SHA384(cString, strlen(cString), digest);
	NSMutableString *hash = [NSMutableString stringWithCapacity: CC_SHA384_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_SHA384_DIGEST_LENGTH; i++) {
		[hash appendFormat: @"%02x", digest[i]];
	}
	return [hash lowercaseString];
}

+ (NSString *) sha512: (NSString *)string {
    const char *cString = [string UTF8String];
    unsigned char digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(cString, strlen(cString), digest);
	NSMutableString *hash = [NSMutableString stringWithCapacity: CC_SHA512_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
		[hash appendFormat: @"%02x", digest[i]];
	}
	return [hash lowercaseString];
}

@end
