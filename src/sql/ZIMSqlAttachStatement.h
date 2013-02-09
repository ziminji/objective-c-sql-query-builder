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
 @class					ZIMSqlAttachStatement
 @discussion			This class represents an SQL attach statement.
 @updated				2011-04-07
 @see					http://www.sqlite.org/lang_attach.html
 */
@interface ZIMSqlAttachStatement : NSObject <ZIMSqlStatement> {

	@protected
		NSString *_fileName;
		NSString *_database;

}
/*!
 @method				database:as:
 @discussion			This method will set the specified database file to be added to the current
						database connection.
 @param fileName		The file name of the database to be attached.
 @param database		The database name that will be used when attached.
 @updated				2011-10-30
 */
- (void) database: (NSString *)fileName as: (NSString *)database;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-10-30
 */
- (NSString *) statement;

@end
