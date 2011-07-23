/*
 * Copyright 2011 Ziminji
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
 @method			construct
 @discussion		This method will construct the alter table statement using the parsed XML schema.
 @updated			2011-07-23
 */
- (void) construct;
@end

@implementation ZIMSqlAlterTableStatement

- (id) initWithXML: (NSData *)before withChanges: (NSData *)after error: (NSError **)error {
	if ((self = [super init])) {
		_table = nil;
		_clause = nil;
        //_depth = 0;
        _counter = 0;
        _error = error;
        if ((before != nil) && (after != nil)) {
			_schema = [[NSMutableDictionary alloc] init];
			NSXMLParser *parser;
			parser = [[NSXMLParser alloc] initWithData: before];
			[parser setDelegate: self];
			BOOL successful = [parser parse];
			[parser release];
			if (successful) {
                _counter = 0;
				parser = [[NSXMLParser alloc] initWithData: after];
            	[parser setDelegate: self];
            	successful = [parser parse];
            	[parser release];
				if (successful) {
					[self construct];
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
    NSError *error;
    return [self initWithXML: nil withChanges: nil error: &error];
}

- (void) dealloc {
	if (_schema != nil) { [_schema release]; }
	[super dealloc];
}

- (void) table: (NSString *)table {
	_table = table;
}

- (void) autoincrement: (NSInteger)position {
	_clause = [NSString stringWithFormat: @"UPDATE [sqlite_sequence] SET [seq] = %d", [ZIMSqlExpression prepareNaturalNumber: position]];
}

- (void) column: (NSString *)column type: (NSString *)type {
	_clause = [NSString stringWithFormat: @"ADD COLUMN %@ %@", column, type];
}

- (void) column: (NSString *)column type: (NSString *)type defaultValue: (NSString *)value {
	_clause = [NSString stringWithFormat: @"ADD COLUMN %@ %@ %@", column, type, value];
}

- (void) column: (NSString *)column type: (NSString *)type primaryKey: (BOOL)primaryKey {
	if (primaryKey) {
		_clause = [NSString stringWithFormat: @"ADD COLUMN %@ %@ PRIMARY KEY", column, type];
	}
	else {
		_clause = [NSString stringWithFormat: @"ADD COLUMN %@ %@", column, type];
	}
}

- (void) column: (NSString *)column type: (NSString *)type unique: (BOOL)unique {
	if (unique) {
		_clause = [NSString stringWithFormat: @"ADD COLUMN %@ %@ UNIQUE", column, type];
	}
	else {
		_clause = [NSString stringWithFormat: @"ADD COLUMN %@ %@", column, type];
	}
}

- (void) rename: (NSString *)table {
	_clause = [NSString stringWithFormat: @"RENAME TO %@", [ZIMSqlExpression prepareIdentifier: table]];
}

- (NSString *) statement {
	if ([_clause hasPrefix: @"UPDATE"]) {
		return [NSString stringWithFormat: @"%@ WHERE [name] = '%@';", _clause, _table];
	}
	return [NSString stringWithFormat: @"ALTER TABLE %@ %@;", [ZIMSqlExpression prepareIdentifier: _table], _clause];
}

- (void) parser: (NSXMLParser *)parser didStartElement: (NSString *)element namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName attributes: (NSDictionary *)attributes {
    if (_counter < 1) {
        if ([element isEqualToString: @"database"]) {
            NSMutableArray *array = [_schema objectForKey: @"database/@name"];
            if (array == nil) {
                array = [[[NSMutableArray alloc] init] autorelease];
                [_schema setObject: array forKey: @"database/@name"];
            }
            [array addObject: [attributes objectForKey: @"name"]];
        }
        if ([element isEqualToString: @"table"]) {
            NSMutableArray *array = [_schema objectForKey: @"database/table/@name"];
            if (array == nil) {
                array = [[[NSMutableArray alloc] init] autorelease];
                [_schema setObject: array forKey: @"database/table/@name"];
            }
            [array addObject: [attributes objectForKey: @"name"]];
        }
        else if ([element isEqualToString: @"column"]) {
            NSMutableArray *array = [_schema objectForKey: @"database/table/column/@*"];
            if (array == nil) {
                array = [[[NSMutableArray alloc] init] autorelease];
                [_schema setObject: array forKey: @"database/table/column/@*"];
            }
            [array addObject: [NSArray arrayWithObjects: [attributes objectForKey: @"name"], attributes, nil]];
        }
    }
}

- (void) parser: (NSXMLParser *)parser didEndElement: (NSString *)element namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName {
    if ([element isEqualToString: @"table"]) {
		_counter++;
	}
}

- (void) parser: (NSXMLParser *)parser parseErrorOccurred: (NSError *)error {
    if (_error) {
        *_error = error;
    }
}

- (void) construct {
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
                    NSString *type = [attributes objectForKey: @"type"];
                    NSString *defaultValue = [attributes objectForKey: @"defaultValue"];
                    if (defaultValue != nil) {
                        [self column: a0 type: type defaultValue: defaultValue];
                    }
                    else {
                        [self column: a0 type: type];
                    }
                    break;
                }
            }
        }
    }    
}

@end
