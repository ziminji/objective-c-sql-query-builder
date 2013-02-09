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

#import "ZIMSqlDropTriggerStatement.h"

@implementation ZIMSqlDropTriggerStatement

- (id) initWithXmlSchema: (NSData *)xml error: (NSError **)error {
	if ((self = [super init])) {
		_trigger = nil;
		_exists = NO;
        _stack = [[NSMutableArray alloc] init];
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

- (void) trigger: (NSString *)trigger {
	[self trigger: trigger exists: NO];
}

- (void) trigger: (NSString *)trigger exists: (BOOL)exists {
	_trigger = [ZIMSqlExpression prepareIdentifier: trigger];
	_exists = exists;
}

- (NSString *) statement {
	NSMutableString *sql = [[NSMutableString alloc] init];
	
	[sql appendString: @"DROP TRIGGER "];
	
	if (_exists) {
		[sql appendString: @"IF EXISTS "];
	}
	
	[sql appendString: _trigger];
	
	[sql appendString: @";"];
	
	return sql;
}

- (void) parser: (NSXMLParser *)parser didStartElement: (NSString *)element namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName attributes: (NSDictionary *)attributes {
	[_stack addObject: element];
	if (_counter < 1) {
        NSString *xpath = [_stack componentsJoinedByString: @"/"];
        if ([xpath isEqualToString: @"database/trigger"]) {
            [self trigger: [attributes objectForKey: @"name"]];
        }
    }
}

- (void) parser: (NSXMLParser *)parser didEndElement: (NSString *)element namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName {
    NSString *xpath = [_stack componentsJoinedByString: @"/"];
    if ([xpath isEqualToString: @"database/trigger"]) {
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
