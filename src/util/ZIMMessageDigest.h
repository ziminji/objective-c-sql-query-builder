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

#import <Foundation/Foundation.h>

/*!
 @class				ZIMMessageDigest
 @discussion		This class creates a message digest algorithmically from a specified string.
 @updated			2011-08-01
 */
@interface ZIMMessageDigest : NSObject {
    
}
/*!
 @method			md2:
 @discussion		This method creates a message digest using the md2 algorithm.
 @param string		The string to be hashed.
 @return			A string representing the message digest.
 @updated			2011-08-01
 @see				http://www.crypo.com/eng_md2.php
 */
+ (NSString *) md2: (NSString *)string;
/*!
 @method			md4:
 @discussion		This method creates a message digest using the md4 algorithm.
 @param string		The string to be hashed.
 @return			A string representing the message digest.
 @updated			2011-08-01
 @see				http://www.crypo.com/eng_md4.php
 */
+ (NSString *) md4: (NSString *)string;
/*!
 @method			md5:
 @discussion		This method creates a message digest using the md5 algorithm.
 @param string		The string to be hashed.
 @return			A string representing the message digest.
 @updated			2011-08-01
 @see				http://www.makebetterthings.com/blogs/uncategorized/how-to-get-md5-and-sha1-in-objective-c-ios-sdk/
 @see				http://www.miniwebtool.com/md5-hash-generator/
 */
+ (NSString *) md5: (NSString *)string;
/*!
 @method			sha1:
 @discussion		This method creates a message digest using the sha1 algorithm.
 @param string		The string to be hashed.
 @return			A string representing the message digest.
 @updated			2011-08-01
 @see				http://www.makebetterthings.com/blogs/uncategorized/how-to-get-md5-and-sha1-in-objective-c-ios-sdk/
 @see				http://www.miniwebtool.com/sha1-hash-generator/
 */
+ (NSString *) sha1: (NSString *)string;
/*!
 @method			sha224:
 @discussion		This method creates a message digest using the sha224 algorithm.
 @param string		The string to be hashed.
 @return			A string representing the message digest.
 @updated			2011-08-01
 @see				http://www.miniwebtool.com/sha224-hash-generator/
 */
+ (NSString *) sha224: (NSString *)string;
/*!
 @method			sha256:
 @discussion		This method creates a message digest using the sha256 algorithm.
 @param string		The string to be hashed.
 @return			A string representing the message digest.
 @updated			2011-08-01
 @see				http://stackoverflow.com/questions/4992109/generate-sha256-string-in-objective-c
 @see				http://www.miniwebtool.com/sha256-hash-generator/
 */
+ (NSString *) sha256: (NSString *)string;
/*!
 @method			sha384:
 @discussion		This method creates a message digest using the sha384 algorithm.
 @param string		The string to be hashed.
 @return			A string representing the message digest.
 @updated			2011-08-01
 @see				http://www.miniwebtool.com/sha384-hash-generator/
 */
+ (NSString *) sha384: (NSString *)string;
/*!
 @method			sha512:
 @discussion		This method creates a message digest using the sha512 algorithm.
 @param string		The string to be hashed.
 @return			A string representing the message digest.
 @updated			2011-08-01
 @see				http://stackoverflow.com/questions/3829068/hash-a-password-string-using-sha512-like-c
 @see				http://www.miniwebtool.com/sha512-hash-generator/
 */
+ (NSString *) sha512: (NSString *)string;

@end
