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

#import "ZIMSqlCreateIndexStatement.h"

@implementation ZIMSqlCreateIndexStatement

- (id) initWithXmlSchema: (NSData *)xml error: (NSError **)error {
	if ((self = [super init])) {
		_unique = NO;
		_index = nil;
		_table = nil;
		_column = [[NSMutableSet alloc] init];
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

- (void) index: (NSString *)index on: (NSString *)table {
	_index = [ZIMSqlExpression prepareIdentifier: index];
	_table = [ZIMSqlExpression prepareIdentifier: table];
}

- (void) unique: (BOOL)unique {
	_unique = unique;
}

- (void) column: (NSString *)column {
    [self column: column descending: NO];
}

- (void) column: (NSString *)column descending: (BOOL)descending {
	[_column addObject: [NSString stringWithFormat: @"%@ %@", [ZIMSqlExpression prepareIdentifier: column], [ZIMSqlExpression prepareSortOrder: descending]]];
}

- (void) columns: (NSSet *)columns {
    [self columns: columns descending: NO];
}

- (void) columns: (NSSet *)columns descending: (BOOL)descending {
	for (NSString *column in columns) {
		[self column: column descending: descending];
	}
}

- (NSString *) statement {
	NSMutableString *sql = [[NSMutableString alloc] init];

	[sql appendString: @"CREATE"];

	if (_unique) {
		[sql appendString: @" UNIQUE"];
	}

	[sql appendFormat: @" INDEX %@ ON %@", _index, _table];
	
	if ([_column count] > 0) {
		[sql appendFormat: @" (%@)", [[_column allObjects] componentsJoinedByString: @", "]];
	}

	[sql appendString: @";"];

	return sql;
}

- (void) parser: (NSXMLParser *)parser didStartElement: (NSString *)element namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName attributes: (NSDictionary *)attributes {
	[_stack addObject: element];
	if (_counter < 1) {
        NSString *xpath = [_stack componentsJoinedByString: @"/"];
        if ([xpath isEqualToString: @"database/index"]) {
            [self index: [attributes objectForKey: @"name"] on: [attributes objectForKey: @"table"]];
            NSString *unique = [attributes objectForKey: @"unique"];
			if ((unique != nil) && [[unique uppercaseString] boolValue]) {
				[self unique: YES];
			}
        }
        else if ([xpath isEqualToString: @"database/index/column"]) {
            NSString *name = [attributes objectForKey: @"name"];
            NSString *order = [attributes objectForKey: @"order"];
			BOOL descending = ((order != nil) && [[order uppercaseString] isEqualToString: @"DESC"]);
			[self column: name descending: descending];
        }
    }
}

- (void) parser: (NSXMLParser *)parser didEndElement: (NSString *)element namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName {
    NSString *xpath = [_stack componentsJoinedByString: @"/"];
	if ([xpath isEqualToString: @"database/index"]) {
		_counter++;
	}
	[_stack removeLastObject];
}

- (void) parser: (NSXMLParser *)parser parseErrorOccurred: (NSError *)error {
    if (_error) {
        _error = error;
    }
}

@end
