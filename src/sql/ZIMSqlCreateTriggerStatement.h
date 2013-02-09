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
#import "ZIMSqlDataDefinitionCommand.h"

/*!
 @class					ZIMSqlCreateTriggerStatement
 @discussion			This class represents an SQL create trigger statement.
 @updated				2012-03-18
 @see					http://www.sqlite.org/lang_createtrigger.html
 @see					http://sqlite.awardspace.info/syntax/sqlitepg11.htm
 */
@interface ZIMSqlCreateTriggerStatement : NSObject <ZIMSqlStatement, ZIMSqlDataDefinitionCommand, NSXMLParserDelegate> {

	@protected
		NSString *_trigger;
		BOOL _temporary;
		NSString *_advice;
		NSString *_event;
		NSMutableArray *_when;
		NSMutableArray *_sql;
		NSMutableArray *_stack;
		NSString *_cdata;
        NSUInteger _counter;
        NSError *_error;

}
/*!
 @method				initWithXmlSchema:error:
 @discussion			This method initializes the class via an XML file following Ziminji's "XML to DDL" schema.
 @param xml	            The UTF-8 encoded string of XML.
 @param error           Used when an error occurs while processing the XML data. May be NULL.
 @return                An instance of this class.
 @updated				2011-10-19
 @see					http://db.apache.org/ddlutils/
 @see					http://db.apache.org/ddlutils/schema/
 */
- (id) initWithXmlSchema: (NSData *)xml error: (NSError **)error;
/*!
 @method				init
 @discussion			This method initializes the class.
 @return                An instance of this class.
 @updated				2012-03-20
 */
- (id) init;
/*!
 @method				trigger:
 @discussion			This method sets the name for the trigger in the SQL statement.
 @param trigger			The trigger's name.
 @updated				2011-07-29
 */
- (void) trigger: (NSString *)trigger;
/*!
 @method				trigger:temporary:
 @discussion			This method sets the name for the trigger in the SQL statement and whether it
						is temporary or not.
 @param trigger			The trigger's name.
 @param temporary		This establishes whether the trigger will be temporary.
 @updated				2011-10-30
 */
- (void) trigger: (NSString *)trigger temporary: (BOOL)temporary;
/*!
 @method				before:
 @discussion			This method causes the trigger to be fired before a specific command executes.
 @updated				2011-07-27
 */
- (void) before;
/*!
 @method				after:
 @discussion			This method causes the trigger to be fired after a specific command executes.
 @updated				2011-07-27
 */
- (void) after;
/*!
 @method				insteadOf:
 @discussion			This method causes the trigger to be fired instead of a specific command.
 @updated				2011-07-27
 */
- (void) insteadOf;
/*!
 @method				onDelete:
 @discussion			This method will cause the trigger to listen for a "DELETE" command on the specified table.
 @param table           The table the trigger will listen on.
 @updated				2011-10-30
 */
- (void) onDelete: (NSString *)table;
/*!
 @method				onInsert:
 @discussion			This method will cause the trigger to listen for an "INSERT" command on the specified table.
 @param table           The table the trigger will listen on.
 @updated				2011-10-30
 */
- (void) onInsert: (NSString *)table;
/*!
 @method				onUpdate:
 @discussion			This method will cause the trigger to listen for an "UPDATE" command on the specified table.
 @param table           The table the trigger will listen on.
 @updated				2011-10-30
 */
- (void) onUpdate: (NSString *)table;
/*!
 @method				onUpdate:column:
 @discussion			This method will cause the trigger to listen for an "UPDATE" command on the specified column in
                        the table.
 @param table           The table the trigger will listen on.
 @param column			The triggering column.
 @updated				2011-10-30
 */
- (void) onUpdate: (NSString *)table column: (NSString *)column;
/*!
 @method				onUpdate:columns:
 @discussion			This method will cause the trigger to listen for an "UPDATE" command on on one or more the specified
                        columns in the table.
 @param table           The table the trigger will listen on.
 @param columns			The triggering columns.
 @updated				2011-10-30
 */
- (void) onUpdate: (NSString *)table columns: (NSSet *)columns;
/*!
 @method				whenBlock:
 @discussion			This method will start or end a block.
 @param brace			The brace to be used; it is either an opening or closing brace.
 @updated				2011-07-27
 */
- (void) whenBlock: (NSString *)brace;
/*!
 @method				whenBlock:connector:
 @discussion			This method will start or end a block.
 @param brace			The brace to be used; it is either an opening or closing brace.
 @param connector		The connector to be used.
 @updated				2011-07-27
 */
- (void) whenBlock: (NSString *)brace connector: (NSString *)connector;
/*!
 @method				when:operator:column:
 @discussion			This method will add a when clause to the SQL statement.
 @param column1			The column to be tested.
 @param operator		The operator to be used.
 @param column2			The column to be compared.
 @updated				2012-03-23
 */
- (void) when: (id)column1 operator: (NSString *)operator column: (id)column2;
/*!
 @method				when:operator:column:connector:
 @discussion			This method will add a when clause to the SQL statement.
 @param column1			The column to be tested.
 @param operator		The operator to be used.
 @param column2			The column to be compared.
 @param connector		The connector to be used.
 @updated				2012-03-23
 */
- (void) when: (id)column1 operator: (NSString *)operator column: (id)column2 connector: (NSString *)connector;
/*!
 @method				when:operator:value:
 @discussion			This method will add a when clause to the SQL statement.
 @param column			The column to be tested.
 @param operator		The operator to be used.
 @param value			The value to be compared.
 @updated				2012-03-23
 */
- (void) when: (id)column operator: (NSString *)operator value: (id)value; // wrap primitives with NSNumber
/*!
 @method				when:operator:value:connector:
 @discussion			This method will add a when clause to the SQL statement.
 @param column			The column to be tested.
 @param operator		The operator to be used.
 @param value			The value to be compared.
 @param connector		The connector to be used.
 @updated				2012-03-23
 */
- (void) when: (id)column operator: (NSString *)operator value: (id)value connector: (NSString *)connector; // wrap primitives with NSNumber
/*!
 @method				sql:
 @discussion			This method will set the SQL statement that will be used.
 @param statement		The SQL statement to be executed.
 @updated				2011-07-27
 */
- (void) sql: (NSString *)statement;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-10-19
 */
- (NSString *) statement;

@end
