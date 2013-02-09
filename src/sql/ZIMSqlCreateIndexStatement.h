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
 @class					ZIMSqlCreateIndexStatement
 @discussion			This class represents an SQL create index statement.
 @updated				2012-03-18
 @see					http://www.sqlite.org/lang_createindex.html
 */
@interface ZIMSqlCreateIndexStatement : NSObject <ZIMSqlStatement, ZIMSqlDataDefinitionCommand, NSXMLParserDelegate> {

	@protected
		NSString *_index;
		NSString *_table;
		BOOL _unique;
		NSMutableSet *_column;
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
 @method				index:on:
 @discussion			This method defines an index on the specified table.
 @param index			The index's name.
 @param table			The table's name.
 @updated				2011-10-30
 */
- (void) index: (NSString *)index on: (NSString *)table;
/*!
 @method				unique:
 @discussion			This method establishes whether the index will be unique.
 @param unique			Establishes whether the index will be unique.
 @updated				2011-07-09
 */
- (void) unique: (BOOL)unique;
/*!
 @method				column:
 @discussion			This method adds the specified column to be indexed.
 @param column			The column to be indexed.
 @updated				2011-07-28
 */
- (void) column: (NSString *)column;
/*!
 @method				column:descending:
 @discussion			This method adds the specified column to be indexed.
 @param column			The column to be indexed.
 @param descending		This will determine whether the column should be ordered in descending order.
 @updated				2011-10-30
 */
- (void) column: (NSString *)column descending: (BOOL)descending;
/*!
 @method				columns:
 @discussion			This method adds the specified columns to be indexed.
 @param columns			The columns to be indexed.
 @updated				2011-07-28
 */
- (void) columns: (NSSet *)columns;
/*!
 @method				column:descending:
 @discussion			This method adds the specified columns to be indexed.
 @param columns			The columns to be indexed.
 @param descending		This will determine whether the column should be ordered in descending order.
 @updated				2011-07-28
 */
- (void) columns: (NSSet *)columns descending: (BOOL)descending;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-10-19
 */
- (NSString *) statement;

@end
