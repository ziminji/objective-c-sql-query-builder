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

// Supported options
#define ZIMOrmOptionLimit						@"LIMIT"
#define ZIMOrmOptionOffset						@"OFFSET"

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
 @method				belongsTo:foreignKey:
 @discussion			This method uses the values stored in the foreign key columns of the current instance (i.e "self")
						to find a record in another table by comparing them against that foreign table's primary key columns.
 @param model			The model type to be loaded.
 @param foreignKey		An array of columns in the current instance that define the foreign key to be used.  The order of
						the columns matters (i.e. columns must be placed in the same order as model's primary key).
 @return				Returns a model of the specified class.
 @updated				2011-05-19
 */
- (id) belongsTo: (Class)model foreignKey: (NSArray *)foreignKey; // the foreign key array is an ordered list of columns in "self"
/*!
 @method				hasOne:foreignKey:
 @discussion			This method uses the values stored in the primary key columns of the current instance (i.e "self")
						to find a record in another table by comparing them against that table's foreign key columns.
 @param model			The model type to be loaded.
 @param foreignKey		An array of columns in the specified model that define the foreign key to be used.  The order of
						the columns matters (i.e. columns must be placed in the same order as self's primary key).
 @return				Returns a model of the specified class.
 @updated				2011-05-04
 */
- (id) hasOne: (Class)model foreignKey: (NSArray *)foreignKey; // i.e. the foreign key array is an ordered list of columns in "model"
/*!
 @method				hasMany:foreignKey:
 @discussion			This method uses the values stored in the primary key columns of the current instance (i.e "self")
						to find a set of records in another table by comparing them against that table's foreign key columns.
 @param model			The model type to be loaded.
 @param foreignKey		An array of columns in the specified model that define the foreign key to be used.  The order of
						the columns matters (i.e. columns must be placed in the same order as self's primary key).
 @return				Returns an array of models of the specified class.
 @updated				2011-05-03
 */
- (NSArray *) hasMany: (Class)model foreignKey: (NSArray *)foreignKey; // i.e. the foreign key array is an ordered list of columns in "model"
/*!
 @method				hasMany:foreignKey:options:
 @discussion			This method uses the values stored in the primary key columns of the current instance (i.e "self")
						to find a set of records in another table by comparing them against that table's foreign key columns.
 @param model			The model type to be loaded.
 @param foreignKey		An array of columns in the specified model that define the foreign key to be used.  The order of
						the columns matters (i.e. columns must be placed in the same order as self's primary key).
 @param options			A dictionary options that will constraint the result set.
 @return				Returns an array of models of the specified class.
 @updated				2011-05-03
 @see					http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html
 */
- (NSArray *) hasMany: (Class)model foreignKey: (NSArray *)foreignKey options: (NSDictionary *)options; // i.e. the foreign key array is an ordered list of columns in "model"
/*!
 @method				delete
 @discussion			This method deletes the record matching the primary key.
 @updated				2011-06-25
 */
- (void) delete;
/*!
 @method				load
 @discussion			This method will load/reload the record matching the primary key.
 @updated				2011-06-25
 */
- (void) load;
/*!
 @method				save
 @discussion			This method either creates or updates the record matching the primary key.
 @updated				2011-06-25
 */
- (void) save;
/*!
 @method				hashCode
 @discussion			This method returns a hash code that is calculated by first concatenating the value
						assigned to each primary key and then finding the SHA1 has for the concatenated string.
 @updated				2011-06-25
 */
- (NSString *) hashCode;
/*!
 @method				dataSource
 @discussion			This method will return the file name of the database.
 @return				The file name of the database to be used.
 @updated				2011-04-16
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
 @updated				2011-04-18
 */
+ (NSArray *) primaryKey; // may be a composite primary key
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
/*!
 @method				isModel:
 @discussion			This method determines whether the specified class is a class of this type.
 @param model			The class to be tested.
 @return				Returns whether the specified class is a class of this type.
 @updated				2011-05-01
 @see					http://cocoawithlove.com/2010/01/getting-subclasses-of-objective-c-class.html
 */
+ (BOOL) isModel: (Class)model;

@end
