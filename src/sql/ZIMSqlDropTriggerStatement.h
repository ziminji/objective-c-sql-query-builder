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
#import "ZIMSqlDataDefinitionCommand.h"

/*!
 @class					ZIMSqlDropTriggerStatement
 @discussion			This class represents an SQL drop trigger statement.
 @updated				2011-07-15
 @see					http://www.sqlite.org/lang_droptrigger.html
 */
@interface ZIMSqlDropTriggerStatement : NSObject <ZIMSqlStatement, ZIMSqlDataDefinitionCommand> {
	
	@protected
		NSString *_trigger;
		BOOL _exists;
	
}
/*!
 @method				trigger:
 @discussion			This method will set the trigger used in the SQL statement.
 @param trigger			The trigger that will be used in the SQL statement.
 @updated				2011-03-18
 */
- (void) trigger: (NSString *)trigger;
/*!
 @method				trigger:exists:
 @discussion			This method will set the trigger used in the SQL statement.
 @param trigger			The trigger that will be used in the SQL statement.
 @param exists			This will determine whether the "IF EXISTS" keywords should added. 
 @updated				2011-03-18
 */
- (void) trigger: (NSString *)trigger exists: (BOOL)exists;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-03-18
 */
- (NSString *) statement;

@end
