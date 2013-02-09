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
 @class					ZIMSqlAlterTableStatement
 @discussion			This class represents an SQL alter table statement.
 @updated				2012-03-18
 @see					http://www.sqlite.org/lang_altertable.html
 */
@interface ZIMSqlAlterTableStatement : NSObject <ZIMSqlStatement, ZIMSqlDataDefinitionCommand, NSXMLParserDelegate> {

	@protected
		NSString *_table;
		NSString *_clause;
		NSMutableDictionary *_schema;
		NSMutableArray *_stack;
		NSUInteger _counter;
		NSError *_error;

}
/*!
 @method				initWithXmlSchema:withChanges:error:
 @discussion			This method initializes the class via an XML file following Ziminji's "XML to DDL" schema.
 @param before			The UTF-8 encoded string of XML.
 @param after			The UTF-8 encoded string of XML with the changes.
 @param error           Used when an error occurs while processing the XML data. May be NULL.
 @return                An instance of this class.
 @updated				2011-10-19
 @see					http://db.apache.org/ddlutils/
 @see					http://db.apache.org/ddlutils/schema/
 */
- (id) initWithXmlSchema: (NSData *)before withChanges: (NSData *)after error: (NSError **)error;
/*!
 @method				init
 @discussion			This method initializes the class.
 @return                An instance of this class.
 @updated				2012-03-20
 */
- (id) init;
/*!
 @method				table:
 @discussion			This method will set the table used in the SQL statement.
 @param table			The table that will be used in the SQL statement.
 @updated				2011-10-30
 */
- (void) table: (NSString *)table;
/*!
 @method				autoincrement:
 @discussion			This method will change the autoincrement position.  WARNING: ALTERING TABLE VIA THIS
						METHOD MAY CAUSE PROBLEMS WITH THE AUTOINCREMENT KEY GENERATION ALGORITHM.
 @param position		The position to which the autoincrementer will be set.
 @updated				2012-03-18
 @see					http://sqlite.org/autoinc.html
 @see					http://stackoverflow.com/questions/3443630/reset-the-row-number-count-in-sqlite3-mysql
 */
- (void) autoincrement: (NSUInteger)position;
/*!
 @method				column:type:
 @discussion			This method will create a column with the specified parameters.
 @param column			The column to be created.
 @param type			The datatype of the column.
 @updated				2011-10-30
 */
- (void) column: (NSString *)column type: (NSString *)type;
/*!
 @method				column:type:defaultValue:
 @discussion			This method will create a column with the specified parameters.
 @param column			The column to be created.
 @param type			The datatype of the column.
 @param value			The default value to be used when no data is provided.
 @updated				2011-10-30
 */
- (void) column: (NSString *)column type: (NSString *)type defaultValue: (NSString *)value;
/*!
 @method				column:type:primaryKey:
 @discussion			This method will create a column with the specified parameters.
 @param column			The column to be created.
 @param type			The datatype of the column.
 @param primaryKey		This marks the specified column as the primary key.
 @updated				2011-10-30
 */
- (void) column: (NSString *)column type: (NSString *)type primaryKey: (BOOL)primaryKey;
/*!
 @method				column:type:unique:
 @discussion			This method will create a column with the specified datatype. It also provides
						the option to ensure that all values in the column are distinct.
 @param column			The column to be created.
 @param type			The datatype of the column.
 @param unique			This constrains the column to only unique values.
 @updated				2011-10-30
 */
- (void) column: (NSString *)column type: (NSString *)type unique: (BOOL)unique;
/*!
 @method				rename:
 @discussion			This method will set the table used in the SQL statement.
 @param table			The table that will be used in the SQL statement.
 @updated				2011-10-30
 */
- (void) rename: (NSString *)table;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-10-30
 */
- (NSString *) statement;

@end
