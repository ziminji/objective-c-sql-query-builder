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
 @class					ZIMSqlDropViewStatement
 @discussion			This class represents an SQL drop view statement.
 @updated				2011-07-15
 @see					http://www.sqlite.org/lang_dropview.html
 */
@interface ZIMSqlDropViewStatement : NSObject <ZIMSqlStatement, ZIMSqlDataDefinitionCommand> {
	
	@protected
		NSString *_view;
		BOOL _exists;
	
}
/*!
 @method				view:
 @discussion			This method will set the view used in the SQL statement.
 @param view			The view that will be used in the SQL statement.
 @updated				2011-03-18
 */
- (void) view: (NSString *)view;
/*!
 @method				view:exists:
 @discussion			This method will set the view used in the SQL statement.
 @param view			The view that will be used in the SQL statement.
 @param exists			This will determine whether the "IF EXISTS" keywords should added. 
 @updated				2011-06-23
 */
- (void) view: (NSString *)view exists: (BOOL)exists;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-03-18
 */
- (NSString *) statement;

@end
