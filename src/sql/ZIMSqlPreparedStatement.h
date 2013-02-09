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
 @class					ZIMSqlPreparedStatement
 @discussion			This class represents a prepared SQL statement.
 @updated				2011-08-13
 */
@interface ZIMSqlPreparedStatement : NSObject <ZIMSqlStatement> {

	@protected
		NSMutableArray *_tokens;
		NSMutableArray *_indicies;

}
/*!
 @method				initWithSqlStatement:
 @discussion			This method initialize the class with the specified SQL statement.
 @param sql				The SQL statement to be prepared.
 @return				An instance of this class.
 @updated				2011-10-19
 */
- (id) initWithSqlStatement: (NSString *)sql;
/*!
 @method				setIdentifier:atIndex:
 @discussion			This method will set an identifier for the parameter with the specified index
						in the SQL statement.
 @param identifier		The identifier to be set.
 @param index			The parameter's index.
 @updated				2012-03-23
 */
- (void) setIdentifier: (id)identifier atIndex: (NSUInteger)index;
/*!
 @method				setValue:atIndex:
 @discussion			This method will set an value for the parameter with the specified index in
						the SQL statement.
 @param value			The value to be set.
 @param index			The parameter's index.
 @updated				2012-03-18
 */
- (void) setValue: (id)value atIndex: (NSUInteger)index;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was prepared.
 @updated				2011-10-19
 */
- (NSString *) statement;
/*!
 @method				preparedStatement:withValues:
 @discussion			This method will return the SQL statement.
 @param sql				The SQL statement to be prepared.
 @param values			The values (i.e. objects) to be set.
 @return				The SQL statement that was prepared.
 @updated				2011-10-19
 */
+ (NSString *) preparedStatement: (NSString *)sql withValues: (id)values, ...;

@end
