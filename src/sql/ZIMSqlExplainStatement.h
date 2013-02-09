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
#import "ZIMSqlDataManipulationCommand.h"

#define ZIMSqlExplainMachineInstructions		0
#define ZIMSqlExplainHighLevelInformation		1

/*!
 @class					ZIMSqlExplainStatement
 @discussion			This class represents an SQL explain statement.
 @updated				2012-03-18
 @see					http://www.sqlite.org/lang_explain.html
 */
@interface ZIMSqlExplainStatement : NSObject <ZIMSqlStatement, ZIMSqlDataManipulationCommand> {

	@protected
		NSUInteger _level;
		NSString *_statement;

}
/*!
 @method				level:
 @discussion			This method will modify the level of data to be return by the SQL statement.
 @param level			The level of data to be returned (i.e. level 0 is for machine instructions and
						level 1 is for high level information).
 @updated				2012-03-18
 */
- (void) level: (NSUInteger)level;
/*!
 @method				sql:
 @discussion			This method will set the SQL statement that will be described.
 @param statement		The SQL statement to be described.
 @updated				2011-06-25
 */
- (void) sql: (id<ZIMSqlStatement>)statement;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-10-19
 */
- (NSString *) statement;

@end
