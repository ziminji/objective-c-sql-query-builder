/*
 * Copyright 2011-2012 Ziminji
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
 @class					ZIMSqlWrapper
 @discussion			This class wraps a raw SQL statement.
 @updated				2012-03-14
 */
@interface ZIMSqlWrapper : NSObject <ZIMSqlStatement> {

	@protected
		NSString *_statement;

}
/*!
 @method				initWithSqlStatement:
 @discussion			This method initialize the class with the specified SQL statement.
 @param sql				The SQL statement to be wrapped.
 @return				An instance of this class.
 @updated				2011-07-15
 */
- (id) initWithSqlStatement: (NSString *)sql;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The wrapped SQL statement.
 @updated				2012-03-14
 */
- (NSString *) statement;
/*!
 @method				sql:
 @discussion			This method will wrap the SQL statement.
 @param sql				The SQL statement to be wrapped
 @return				The wrapped SQL statement.
 @updated				2012-03-14
 */
+ (NSString *) sql: (NSString *)sql;

@end
