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
 @class					ZIMSqlDetachStatement
 @discussion			This class represents an SQL detach statement.
 @updated				2011-04-07
 @see					http://www.sqlite.org/lang_detach.html
 */
@interface ZIMSqlDetachStatement : NSObject <ZIMSqlStatement> {

	@protected
		NSString *_database;

}
/*!
 @method				database:
 @discussion			This method will cause the specified database to be detached from the current
						database connection.
 @param database		The database name that will be detached.
 @updated				2011-10-30
 */
- (void) database: (NSString *)database;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-04-07
 */
- (NSString *) statement;

@end
