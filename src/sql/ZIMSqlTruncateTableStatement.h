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

#import "ZIMSqlStatement.h"
#import "ZIMSqlDataDefinitionCommand.h"

/*!
 @class					ZIMSqlTruncateTableStatement
 @discussion			This class represents an SQL truncate table statement. Execute as a transaction.
 @updated				2011-11-01
 @see					http://dev.mysql.com/doc/refman/5.0/en/truncate-table.html
 @see					http://stackoverflow.com/questions/3443630/reset-the-row-number-count-in-sqlite3-mysql
 */
@interface ZIMSqlTruncateTableStatement : NSObject <ZIMSqlStatement, ZIMSqlDataDefinitionCommand> {

	@protected
		NSString *_tableIdentifier;
		NSString *_tableName;

}
/*!
 @method				table:
 @discussion			This method will set the table used in the SQL statement.
 @param table			The table that will be used in the SQL statement.
 @updated				2012-03-20
 */
- (void) table: (NSString *)table;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-11-01
 */
- (NSString *) statement;

@end
