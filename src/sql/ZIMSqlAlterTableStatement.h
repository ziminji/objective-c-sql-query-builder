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

#import "ZIMSqlStatement.h"

/*!
 @class					ZIMSqlAlterTableStatement
 @discussion			This class represents an SQL alter table statement.
 @updated				2011-04-07
 @see					http://www.sqlite.org/lang_altertable.html
 */
@interface ZIMSqlAlterTableStatement : NSObject <ZIMSqlStatement> {

	@protected
		NSString *_table;
		NSString *_clause;

}
/*!
 @method				table:
 @discussion			This method will set the table used in the SQL statement.
 @param table			The table that will be used in the SQL statement.
 @updated				2011-06-20
 */
- (void) table: (NSString *)table;
/*!
 @method				autoincrement:
 @discussion			This method will change the autoincrement position.  WARNING: ALTERING TABLE VIA THIS
						METHOD MAY CAUSE PROBLEMS WITH THE AUTOINCREMENT KEY GENERATION ALGORITHM.
 @param position		The position to which the autoincrementer will be set.
 @updated				2011-06-20
 @see					http://sqlite.org/autoinc.html
 @see					http://stackoverflow.com/questions/3443630/reset-the-row-number-count-in-sqlite3-mysql
 */
- (void) autoincrement: (NSInteger)position;
/*!
 @method				column:type:
 @discussion			This method will create a column with the specified parameters.
 @param column			The column to be created.
 @param type			The datatype of the column.
 @updated				2011-03-29
 */
- (void) column: (NSString *)column type: (NSString *)type;
/*!
 @method				column:type:defaultValue:
 @discussion			This method will create a column with the specified parameters.
 @param column			The column to be created.
 @param type			The datatype of the column.
 @param value			The default value to be used when no data is provided.
 @updated				2011-06-26
 */
- (void) column: (NSString *)column type: (NSString *)type defaultValue: (NSString *)value;
/*!
 @method				column:type:primaryKey:
 @discussion			This method will create a column with the specified parameters.
 @param column			The column to be created.
 @param type			The datatype of the column.
 @param primaryKey		This marks the specified column as the primary key.
 @updated				2011-03-29
 */
- (void) column: (NSString *)column type: (NSString *)type primaryKey: (BOOL)primaryKey;
/*!
 @method				column:type:unique:
 @discussion			This method will create a column with the specified datatype. It also provides
						the option to ensure that all values in the column are distinct.
 @param column			The column to be created.
 @param type			The datatype of the column.
 @param unique			This constrains the column to only unique values.
 @updated				2011-03-29
 */
- (void) column: (NSString *)column type: (NSString *)type unique: (BOOL)unique;
/*!
 @method				rename:
 @discussion			This method will set the table used in the SQL statement.
 @param table			The table that will be used in the SQL statement.
 @updated				2011-03-29
 */
- (void) rename: (NSString *)table;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-06-20
 */
- (NSString *) statement;

@end
