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

#import "ZIMSqlCreateTriggerStatement.h"

@implementation ZIMSqlCreateTriggerStatement

- (id) initWithXmlSchema: (NSData *)xml error: (NSError **)error {
	if ((self = [super init])) {
		_trigger = nil;
		_temporary = NO;
		_advice = @"BEFORE";
		_event = nil;
		_when = [[NSMutableArray alloc] init];
		_sql = [[NSMutableArray alloc] init];
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

- (void) trigger: (NSString *)trigger {
	[self trigger: trigger temporary: NO];
}

- (void) trigger: (NSString *)trigger temporary: (BOOL)temporary {
	_trigger = [ZIMSqlExpression prepareIdentifier: trigger];
	_temporary = temporary;
}

- (void) before {
	_advice = @"BEFORE";
}

- (void) after {
	_advice = @"AFTER";
}

- (void) insteadOf {
	_advice = @"INSTEAD OF";
}

- (void) onDelete: (NSString *)table {
    _event = [NSString stringWithFormat: @"DELETE ON %@", [ZIMSqlExpression prepareIdentifier: table]];
}

- (void) onInsert: (NSString *)table {
    _event = [NSString stringWithFormat: @"INSERT ON %@", [ZIMSqlExpression prepareIdentifier: table]];
}

- (void) onUpdate: (NSString *)table {
    _event = [NSString stringWithFormat: @"UPDATE ON %@", [ZIMSqlExpression prepareIdentifier: table]];
}

- (void) onUpdate: (NSString *)table column: (NSString *)column {
    _event = [NSString stringWithFormat: @"UPDATE OF %@ ON %@", [ZIMSqlExpression prepareIdentifier: column], [ZIMSqlExpression prepareIdentifier: table]];
}

- (void) onUpdate: (NSString *)table columns: (NSSet *)columns {
	NSMutableString *buffer = [[NSMutableString alloc] init];
	int index = 0;
	for (NSString *column in columns) {
		if (index > 0) {
			[buffer appendString: @", "];
		}
		[buffer appendString: [ZIMSqlExpression prepareIdentifier: column]];
		index++;
	}
    _event = [NSString stringWithFormat: @"UPDATE OF %@ ON %@", buffer, [ZIMSqlExpression prepareIdentifier: table]];
}

- (void) whenBlock: (NSString *)brace {
	[self whenBlock: brace connector: ZIMSqlConnectorAnd];
}

- (void) whenBlock: (NSString *)brace connector: (NSString *)connector {
	[_when addObject: [NSArray arrayWithObjects: [ZIMSqlExpression prepareConnector: connector], [ZIMSqlExpression prepareEnclosure: brace], nil]];
}

- (void) when: (id)column1 operator: (NSString *)operator column: (id)column2 {
	[self when: column1 operator: operator column: column2 connector: ZIMSqlConnectorAnd];
}

- (void) when: (id)column1 operator: (NSString *)operator column: (id)column2 connector: (NSString *)connector {
	[_when addObject: [NSArray arrayWithObjects: [ZIMSqlExpression prepareConnector: connector], [NSString stringWithFormat: @"%@ %@ %@", [ZIMSqlExpression prepareIdentifier: column1], [operator uppercaseString], [ZIMSqlExpression prepareIdentifier: column2]], nil]];
}

- (void) when: (id)column operator: (NSString *)operator value: (id)value {
	[self when: column operator: operator value: value connector: ZIMSqlConnectorAnd];
}

- (void) when: (id)column operator: (NSString *)operator value: (id)value connector: (NSString *)connector {
	operator = [operator uppercaseString];
	if ([operator isEqualToString: ZIMSqlOperatorBetween] || [operator isEqualToString: ZIMSqlOperatorNotBetween]) {
		if (![value isKindOfClass: [NSArray class]]) {
			@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Operator requires the value to be declared as an array." userInfo: nil];
		}
		[_when addObject: [NSArray arrayWithObjects: [ZIMSqlExpression prepareConnector: connector], [NSString stringWithFormat: @"%@ %@ %@ AND %@", [ZIMSqlExpression prepareIdentifier: column], operator, [ZIMSqlExpression prepareValue: [(NSArray *)value objectAtIndex: 0]], [ZIMSqlExpression prepareValue: [(NSArray *)value objectAtIndex: 1]]], nil]];
	}
	else {
		if (([operator isEqualToString: ZIMSqlOperatorIn] || [operator isEqualToString: ZIMSqlOperatorNotIn]) && ![value isKindOfClass: [NSArray class]]) {
			@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Operator requires the value to be declared as an array." userInfo: nil];
		}
		else if ([value isKindOfClass: [NSNull class]]) {
			if ([operator isEqualToString: ZIMSqlOperatorEqualTo]) {
				operator = ZIMSqlOperatorIs;
			}
			else if ([operator isEqualToString: ZIMSqlOperatorNotEqualTo] || [operator isEqualToString: @"!="]) {
				operator = ZIMSqlOperatorIsNot;
			}
		}
		[_when addObject: [NSArray arrayWithObjects: [ZIMSqlExpression prepareConnector: connector], [NSString stringWithFormat: @"%@ %@ %@", [ZIMSqlExpression prepareIdentifier: column], operator, [ZIMSqlExpression prepareValue: value]], nil]];
	}
}

- (void) sql: (NSString *)statement {
	[_sql addObject: [statement stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @" ;\n\r\t\f"]]];
}

- (NSString *) statement {
	NSMutableString *sql = [[NSMutableString alloc] init];
	
	[sql appendString: @"CREATE"];

	if (_temporary) {
		[sql appendString: @" TEMPORARY"];
	}
	
	[sql appendFormat: @" TRIGGER %@ %@ %@", _trigger, _advice, _event];

    [sql appendString: @" FOR EACH ROW"];

    if ([_when count] > 0) {
		BOOL doAppendConnector = NO;
		[sql appendString: @" WHEN "];
		for (NSArray *when in _when) {
			NSString *whenClause = [when objectAtIndex: 1];
			if (doAppendConnector && ![whenClause isEqualToString: ZIMSqlEnclosureClosingBrace]) {
				[sql appendFormat: @" %@ ", [when objectAtIndex: 0]];
			}
			[sql appendString: whenClause];
			doAppendConnector = (![whenClause isEqualToString: ZIMSqlEnclosureOpeningBrace]);
		}
	}

    if ([_sql count] > 0) {
        [sql appendString: @" BEGIN"];
        for (NSString *stmt in _sql) {
            [sql appendFormat: @" %@;", stmt];
        }
        [sql appendString: @" END"];
    }

	[sql appendString: @";"];
	
	return sql;
}

- (void) parser: (NSXMLParser *)parser didStartElement: (NSString *)element namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName attributes: (NSDictionary *)attributes {
	[_stack addObject: element];
	if (_counter < 1) {
        NSString *xpath = [_stack componentsJoinedByString: @"/"];
        if ([xpath isEqualToString: @"database/trigger"]) {
            NSString *name = [attributes objectForKey: @"name"];
			NSString *temporary = [attributes objectForKey: @"temporary"];
			if ((temporary != nil) && [[temporary uppercaseString] boolValue]) {
				[self trigger: name temporary: YES];
			}
			else {
				[self trigger: name];
			}
            NSString *advice = [[attributes objectForKey: @"advice"] lowercaseString];
            if ([advice isEqualToString: @"before"]) {
                [self before];
            }
            else if ([advice isEqualToString: @"after"]) {
                [self after];
            }
            else if ([advice isEqualToString: @"instead-of"]) {
                [self insteadOf];
            }
            NSString *event = [[attributes objectForKey: @"event"] lowercaseString];
            NSString *table = [attributes objectForKey: @"table"];
            if ([event isEqualToString: @"delete"]) {
                [self onDelete: table];
            }
            else if ([event isEqualToString: @"insert"]) {
                [self onInsert: table];
            }
            else if ([event isEqualToString: @"update"]) {
                [self onUpdate: table];
            }
        }
        else if ([xpath isEqualToString: @"database/trigger/column"]) {
            
        }
        else if ([xpath isEqualToString: @"database/trigger/when"]) {
            
        }
    }
}

- (void) parser: (NSXMLParser *)parser didEndElement: (NSString *)element namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName {
    NSString *xpath = [_stack componentsJoinedByString: @"/"];
    if ([xpath isEqualToString: @"database/trigger"]) {
        _counter++;
    }
    else if ([xpath isEqualToString: @"database/trigger/action"]) {
        [self sql: _cdata];
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
