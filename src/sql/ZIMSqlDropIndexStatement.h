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
 @class					ZIMSqlDropIndexStatement
 @discussion			This class represents an SQL drop index statement.
 @updated				2012-03-18
 @see					http://www.sqlite.org/lang_dropindex.html
 */
@interface ZIMSqlDropIndexStatement : NSObject <ZIMSqlStatement, ZIMSqlDataDefinitionCommand, NSXMLParserDelegate> {
	
	@protected
		NSString *_index;
		BOOL _exists;
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
 @method				index:
 @discussion			This method will set the index used in the SQL statement.
 @param index			The index that will be used in the SQL statement.
 @updated				2011-03-18
 */
- (void) index: (NSString *)index;
/*!
 @method				index:exists:
 @discussion			This method will set the index used in the SQL statement.
 @param index			The index that will be used in the SQL statement.
 @param exists			This will determine whether the "IF EXISTS" keywords should added. 
 @updated				2011-10-30
 */
- (void) index: (NSString *)index exists: (BOOL)exists;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-10-19
 */
- (NSString *) statement;

@end
