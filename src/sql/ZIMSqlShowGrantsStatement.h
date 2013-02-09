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
 @class					ZIMSqlShowGrantsStatement
 @discussion			This class represents an SQL show grants statement.
 @updated				2011-11-05
 @see					http://dev.mysql.com/doc/refman/5.6/en/show-grants.html
 */
@interface ZIMSqlShowGrantsStatement : NSObject <ZIMSqlStatement> {

	@protected
		NSDictionary *_plist;
		NSString *_dataSource;

}
/*!
 @method				forGrantee:
 @discussion			This method will set the data source account to be used.
 @param dataSource		The data source account that will be utilized to generate the SQL statement.
 @updated				2011-11-05
 */
- (void) forGrantee: (NSString *)dataSource;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-11-05
 @see					http://stackoverflow.com/questions/8017633/how-can-i-query-a-list-of-values-into-a-column-of-rows-using-sqlite
 */
- (NSString *) statement;

@end
