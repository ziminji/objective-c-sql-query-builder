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
 @class					ZIMSqlCreateTableStatement
 @discussion			This class represents an SQL create table statement.
 @updated				2012-03-18
 @see					http://www.sqlite.org/lang_createtable.html
 */
@interface ZIMSqlCreateTableStatement : NSObject <ZIMSqlStatement, ZIMSqlDataDefinitionCommand, NSXMLParserDelegate> {

	@protected
		NSString *_table;
		BOOL _temporary;
		NSMutableDictionary *_columnDictionary;
		NSMutableArray *_columnArray;
		NSString *_primaryKey;
		NSString *_unique;
		NSMutableArray *_stack;
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
 @method				table:
 @discussion			This method sets the name for the table in the SQL statement.
 @param table			The table's name.
 @updated				2011-06-26
 */
- (void) table: (NSString *)table;
/*!
 @method				table:temporary:
 @discussion			This method sets the name for the table in the SQL statement and whether it
						is temporary or not.
 @param table			The table's name.
 @param temporary		This establishes whether the table will be temporary.
 @updated				2011-10-30
 */
- (void) table: (NSString *)table temporary: (BOOL)temporary;
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
 @method				primaryKey:
 @discussion			This method will set the specified columns to be the (composite) primary key.
 @param columns			The columns to be set as the (composite) primary key.
 @updated				2011-11-01
 */
- (void) primaryKey: (NSArray *)columns;
/*!
 @method				unique:
 @discussion			This method will apply a unique constraint across the specified columns.
 @param columns			The columns to be constrained.
 @updated				2011-11-01
 */
- (void) unique: (NSArray *)columns;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-10-19
 */
- (NSString *) statement;

@end
