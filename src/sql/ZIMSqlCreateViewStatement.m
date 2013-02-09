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

#import "ZIMSqlCreateViewStatement.h"

@implementation ZIMSqlCreateViewStatement

- (id) initWithXmlSchema: (NSData *)xml error: (NSError **)error {
	if ((self = [super init])) {
		_view = nil;
		_temporary = NO;
		_statement = nil;
        _stack = [[NSMutableArray alloc] init];
		_cdata = nil;
        _counter = 0;
        _error = *error;
        if (xml != nil) {
			NSXMLParser *parser = [[NSXMLParser alloc] initWithData: xml];
			[parser setDelegate: self];
			[parser parse];
		}
	}
	return self;
}

- (id) init {
    NSError *error = nil;
    return [self initWithXmlSchema: nil error: &error];
}

- (void) view: (NSString *)view {
	[self view: view temporary: NO];
}

- (void) view: (NSString *)view temporary: (BOOL)temporary {
	_view = [ZIMSqlExpression prepareIdentifier: view];
	_temporary = temporary;
}

- (void) sql: (NSString *)statement {
	_statement = [statement stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @" ;\n\r\t\f"]];
}

- (NSString *) statement {
	NSMutableString *sql = [[NSMutableString alloc] init];

	[sql appendString: @"CREATE "];

	if (_temporary) {
		[sql appendString: @"TEMPORARY "];
	}
	
	[sql appendFormat: @"VIEW %@ AS ", _view];

	[sql appendString: _statement];
	
	[sql appendString: @";"];

	return sql;
}

- (void) parser: (NSXMLParser *)parser didStartElement: (NSString *)element namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName attributes: (NSDictionary *)attributes {
	[_stack addObject: element];
	if (_counter < 1) {
        NSString *xpath = [_stack componentsJoinedByString: @"/"];
        if ([xpath isEqualToString: @"database/view"]) {
			NSString *name = [attributes objectForKey: @"name"];
			NSString *temporary = [attributes objectForKey: @"temporary"];
			if ((temporary != nil) && [[temporary uppercaseString] boolValue]) {
				[self view: name temporary: YES];
			}
			else {
				[self view: name];
			}
        }
    }
}

- (void) parser: (NSXMLParser *)parser didEndElement: (NSString *)element namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName {
    NSString *xpath = [_stack componentsJoinedByString: @"/"];
    if ([xpath isEqualToString: @"database/view"]) {
		[self sql: _cdata];
        _counter++;
    }
	[_stack removeLastObject];
}

- (void) parser: (NSXMLParser *)parser foundCDATA: (NSData *)CDATABlock {
	_cdata = [[NSString alloc] initWithData: CDATABlock encoding: NSUTF8StringEncoding];
}

- (void) parser: (NSXMLParser *)parser parseErrorOccurred: (NSError *)error {
    if (_error) {
        _error = error;
    }
}

@end
