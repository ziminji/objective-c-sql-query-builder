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

/*!
 @class					ZIMSqlShowColumnsStatement
 @discussion			This class represents an SQL show columns statement.
 @updated				2011-07-31
 @see					http://dev.mysql.com/doc/refman/5.0/en/show-columns.html
 @see					http://stackoverflow.mobi/question763516_information-schema-columns-on-sqlite.aspx
 @see					http://www.sqlite.org/pragma.html
 */
@interface ZIMSqlShowColumnsStatement : NSObject <ZIMSqlStatement> {

	@protected
		NSString *_table;

}
/*!
 @method				from:
 @discussion			This method will set the name of the table in the from clause.
 @param table			The name of table to used in the clause.
 @updated				2011-07-31
 */
- (void) from: (NSString *)table;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-07-31
 */
- (NSString *) statement;

@end
