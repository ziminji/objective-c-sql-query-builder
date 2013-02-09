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

#import "ZIMSqlAlterTableStatement.h"

/*!
 @category		ZIMSqlAlterTableStatement (Private)
 @discussion	This category defines the prototpes for this class's private methods.
 @updated		2011-07-23
 */
@interface ZIMSqlAlterTableStatement (Private)
/*!
 @method			load
 @discussion		This method will construct the alter table statement using the parsed XML schema.
 @updated			2011-07-30
 */
- (void) load;
@end

@implementation ZIMSqlAlterTableStatement

- (id) initWithXmlSchema: (NSData *)before withChanges: (NSData *)after error: (NSError **)error {
	if ((self = [super init])) {
		_table = nil;
		_clause = nil;
        _stack = [[NSMutableArray alloc] init];
        _counter = 0;
        _error = *error;
        if ((before != nil) && (after != nil)) {
			_schema = [[NSMutableDictionary alloc] init];
			NSXMLParser *parser = [[NSXMLParser alloc] initWithData: before];
			[parser setDelegate: self];
			BOOL successful = [parser parse];
			if (successful) {
                _counter = 0;
				parser = [[NSXMLParser alloc] initWithData: after];
            	[parser setDelegate: self];
            	successful = [parser parse];
				if (successful) {
					[self load];
				}
			}
		}
		else {
			_schema = nil;
		}
	}
	return self;
}

- (id) init {
    NSError *error = nil;
    return [self initWithXmlSchema: nil withChanges: nil error: &error];
}

- (void) table: (NSString *)table {
	_table = table; // prepared later
}

- (void) autoincrement: (NSUInteger)position {
	_clause = [NSString stringWithFormat: @"UPDATE [sqlite_sequence] SET [seq] = %u", position];
}

- (void) column: (NSString *)column type: (NSString *)type {
	_clause = [NSString stringWithFormat: @"ADD COLUMN %@ %@", [ZIMSqlExpression prepareIdentifier: column], type];
}

- (void) column: (NSString *)column type: (NSString *)type defaultValue: (NSString *)value {
	_clause = [NSString stringWithFormat: @"ADD COLUMN %@ %@ %@", [ZIMSqlExpression prepareIdentifier: column], type, value];
}

- (void) column: (NSString *)column type: (NSString *)type primaryKey: (BOOL)primaryKey {
	if (primaryKey) {
		_clause = [NSString stringWithFormat: @"ADD COLUMN %@ %@ PRIMARY KEY", [ZIMSqlExpression prepareIdentifier: column], type];
	}
	else {
		_clause = [NSString stringWithFormat: @"ADD COLUMN %@ %@", [ZIMSqlExpression prepareIdentifier: column], type];
	}
}

- (void) column: (NSString *)column type: (NSString *)type unique: (BOOL)unique {
	if (unique) {
		_clause = [NSString stringWithFormat: @"ADD COLUMN %@ %@ UNIQUE", [ZIMSqlExpression prepareIdentifier: column], type];
	}
	else {
		_clause = [NSString stringWithFormat: @"ADD COLUMN %@ %@", [ZIMSqlExpression prepareIdentifier: column], type];
	}
}

- (void) rename: (NSString *)table {
	_clause = [NSString stringWithFormat: @"RENAME TO %@", [ZIMSqlExpression prepareIdentifier: table]];
}

- (NSString *) statement {
	if ([_clause hasPrefix: @"UPDATE"]) {
		return [NSString stringWithFormat: @"%@ WHERE [name] = %@;", _clause, [ZIMSqlExpression prepareValue: _table]];
	}
	return [NSString stringWithFormat: @"ALTER TABLE %@ %@;", [ZIMSqlExpression prepareIdentifier: _table], _clause];
}

- (void) parser: (NSXMLParser *)parser didStartElement: (NSString *)element namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName attributes: (NSDictionary *)attributes {
	[_stack addObject: element];
	if (_counter < 1) {
        NSString *xpath = [_stack componentsJoinedByString: @"/"];
        if ([xpath isEqualToString: @"database"]) {
            NSMutableArray *array = [_schema objectForKey: @"database/@name"];
            if (array == nil) {
                array = [[NSMutableArray alloc] init];
                [_schema setObject: array forKey: @"database/@name"];
            }
            [array addObject: [attributes objectForKey: @"name"]];
        }
        else if ([xpath isEqualToString: @"database/table"]) {
            NSMutableArray *array = [_schema objectForKey: @"database/table/@name"];
            if (array == nil) {
                array = [[NSMutableArray alloc] init];
                [_schema setObject: array forKey: @"database/table/@name"];
            }
            [array addObject: [attributes objectForKey: @"name"]];
        }
        else if ([xpath isEqualToString: @"database/table/column"]) {
            NSMutableArray *array = [_schema objectForKey: @"database/table/column/@*"];
            if (array == nil) {
                array = [[NSMutableArray alloc] init];
                [_schema setObject: array forKey: @"database/table/column/@*"];
            }
            [array addObject: [NSArray arrayWithObjects: [attributes objectForKey: @"name"], attributes, nil]];
        }
    }
}

- (void) parser: (NSXMLParser *)parser didEndElement: (NSString *)element namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName {
    NSString *xpath = [_stack componentsJoinedByString: @"/"];
    if ([xpath isEqualToString: @"database/table"]) {
        _counter++;
    }
	[_stack removeLastObject];
}

- (void) parser: (NSXMLParser *)parser parseErrorOccurred: (NSError *)error {
    if (_error) {
        _error = error;
    }
}

- (void) load {
    NSMutableArray *array = [_schema objectForKey: @"database/@name"];
    NSString *a0 = [array objectAtIndex: 0];
    NSString *a1 = [array objectAtIndex: 1];
    if ([a0 isEqualToString: a1]) {
        array = [_schema objectForKey: @"database/table/@name"];
        a0 = [array objectAtIndex: 0];
        a1 = [array objectAtIndex: 1];
        [self table: a0];
        if (![a0 isEqualToString: a1]) {
            [self rename: a1];
        }
        else {
            array = [_schema objectForKey: @"database/table/column/@*"];
            int size = [array count];
            for (int i = 0; i < size; i++) {
                NSArray *column = [array objectAtIndex: i];
                a0 = [column objectAtIndex: 0];
                BOOL found = NO;
                for (int j = 0; j < size; j++) {
                    if (i != j) {
                        a1 = [[array objectAtIndex: j] objectAtIndex: 0];
                        if ([a0 isEqualToString: a1]) {
                            found = YES;
                            break;
                        }
                    }
                }
                if (!found) {
                    NSDictionary *attributes = [column objectAtIndex: 1];
                    NSString *columnType = [attributes objectForKey: @"type"];
                    NSString *columnValue = [attributes objectForKey: @"default"];
                    if (columnValue != nil) {
                        [self column: a0 type: columnType defaultValue: columnValue];
                    }
                    else {
                        [self column: a0 type: columnType];
                    }
                    break;
                }
            }
        }
    }    
}

@end
