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
 @class					ZIMSqlShowTablesStatement
 @discussion			This class represents an SQL show tables statement.
 @updated				2011-08-13
 @see					http://dev.mysql.com/doc/refman/5.0/en/show-tables.html
 @see					http://venublog.com/2010/02/03/show-temporary-tables/
 @see					http://www.sqlite.org/faq.html#q7
 */
@interface ZIMSqlShowTablesStatement : NSObject <ZIMSqlStatement> {

	@protected
		NSString *_from;
		NSString *_like;

}
/*!
 @method				show:
 @discussion			This method can be used to designate the type of tables to be shown.
 @param type			The type of tables to be shown.
 @updated				2012-03-24
 */
- (void) show: (NSString *)type;
/*!
 @method				like:
 @discussion			This method will constrain the query to only those tables that match the
						specified value.
 @param value			The value to be compared against.
 @updated				2011-08-12
 */
- (void) like: (NSString *)value;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-11-03
 @see					http://www.sqlite.org/lang_createtable.html
 */
- (NSString *) statement;

@end
