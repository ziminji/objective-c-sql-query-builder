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

#import <Foundation/Foundation.h>

/*!
 @class					ZIMOrmModel
 @discussion			This class acts as the base model.
 @updated				2011-04-14
 */
@interface ZIMOrmModel : NSObject {

	@protected
		NSString *_saved;

}
/*!
 @method				delete
 @discussion			This method deletes the record matching the primary key.
 @updated				2011-04-14
 */
- (void) delete;
/*!
 @method				save
 @discussion			This method either creates or updates the record matching the primary key.
 @updated				2011-04-14
 */
- (void) save;
/*!
 @method				hashCode
 @discussion			This method return a hash code that is calculated by first concatenating the value
						assigned to each primary key and then finding the SHA1 has for the concatenated string.
 @updated				2011-04-14
 @see
 */
- (NSString *) hashCode;
/*!
 @method				dataSource
 @discussion			This method will return the file name of the database.
 @return				The file name of the database to be used.
 @updated				2011-04-03
 */
+ (NSString *) dataSource;
/*!
 @method				table
 @discussion			This method will return the table name associated with this class.
 @return				The table name associated with this class.
 @updated				2011-04-03
 */
+ (NSString *) table;
/*!
 @method				primaryKey
 @discussion			This method will return the table's primary key.
 @return				The table's primary key.
 @updated				2011-04-14
 */
+ (NSSet *) primaryKey; // may be a composite primary key
/*!
 @method				isAutoIncremented
 @discussion			This method returns whether the table's primary key auto-increments.
 @return				Returns whether the table's primary key auto-increments.
 @updated				2011-04-14
 */
+ (BOOL) isAutoIncremented;
/*!
 @method				columns
 @discussion			This method will return the table name associated with this class.
 @return				A list of name/type pairs.
 @updated				2011-04-14
 @see					http://stackoverflow.com/questions/1213901/how-do-i-list-all-instance-variables-of-a-class-in-objective-c
 @see					http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
 */
+ (NSDictionary *) columns;
/*!
 @method				isSaveable
 @discussion			This method returns whether the model can be saved to the database.
 @return				Returns whether the model can be saved to the database.
 @updated				2011-04-14
 */
+ (BOOL) isSaveable;

@end
