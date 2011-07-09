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
 @class					ZIMSqlCreateIndexStatement
 @discussion			This class represents an SQL create index statement.
 @updated				2011-07-09
 @see					http://www.sqlite.org/lang_createindex.html
 */
@interface ZIMSqlCreateIndexStatement : NSObject <ZIMSqlStatement> {

	@protected
		NSString *_index;
		NSString *_table;
		BOOL _unique;
		NSMutableSet *_column;

}
/*!
 @method				index:on:
 @discussion			This method defines an index on the specified table.
 @param index			The index's name.
 @param table			The table's name.
 @updated				2011-07-09
 */
- (void) index: (NSString *)index on: (NSString *)table;
/*!
 @method				unique:
 @discussion			This method establishes whether the index will be unique.
 @param unique			Establishes whether the index will be unique.
 @updated				2011-07-09
 */
- (void) unique: (BOOL)unique;
/*!
 @method				column:
 @discussion			This method adds the specified column to be indexed.
 @param column			The column to be indexed.
 @updated				2011-07-09
 */
- (void) column: (NSString *)column;
/*!
 @method				columns:
 @discussion			This method adds the specified columns to be indexed.
 @param columns			The columns to be indexed.
 @updated				2011-07-09
 */
- (void) columns: (NSSet *)columns;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-07-09
 */
- (NSString *) statement;

@end
