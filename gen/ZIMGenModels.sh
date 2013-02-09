#!/bin/bash

##
# Copyright 2011-2013 Ziminji
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
# 
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##

##
# INSTRUCTIONS
#
# Before running this BASH script, configure the associated Java properties file.
#
# To run this BASH script, use the following commands:
# 	username$ chmod +x ZIMGenModels.sh 
# 	username$ ./ZIMGenModels.sh ZIMGenModels.properties
##

##
# Defines reserved words.
##
declare -a RESERVED_TOKENS=( 'alloc' 'autorelease' 'class' 'columns' 'conformsToProtocol' 'dataSource' 'dealloc' 'delegate' 'delete' 'description' 'hash' 'hashCode' 'id' 'init' 'isAutoIncremented' 'isEqual' 'isKindOfClass' 'isMemberOfClass' 'isProxy' 'isSaveable' 'load' 'performSelector' 'primaryKey' 'release' 'respondsToSelector' 'retain' 'retainCount' 'save' 'saved' 'self' 'superclass' 'table' 'zone' )

##
# Defines the hashmap for translating columns.
##
declare -r DATATYPES="BIGINT:NSNumber|BIT:NSNumber|BOOL:NSNumber|BOOLEAN:NSNumber|INT:NSNumber|INT2:NSNumber|INT8:NSNumber|INTEGER:NSNumber|MEDIUMINT:NSNumber|SMALLINT:NSNumber|TINYINT:NSNumber|DECIMAL:NSDecimalNumber|DOUBLE:NSDecimalNumber|DOUBLE PRECISION:NSDecimalNumber|FLOAT:NSDecimalNumber|NUMERIC:NSDecimalNumber|REAL:NSDecimalNumber|CHAR:NSString|CHARACTER:NSString|CLOB:NSString|NATIONAL VARYING CHARACTER:NSString|NATIVE CHARACTER:NSString|NCHAR:NSString|NVARCHAR:NSString|TEXT:NSString|VARCHAR:NSString|VARIANT:NSString|VARYING CHARACTER:NSString|BINARY:NSData|BLOB:NSData|VARBINARY:NSData|NULL:NSNull|DATE:NSDate|DATETIME:NSDate|TIME:NSDate|TIMESTAMP:NSDate"

##
# Defines date related constants.
##
declare -r DATE_CREATED=$(date +%m/%d/%y)
declare -r YEAR=$(date +%Y)
declare -r DATE_MODIFIED=$(date +%F)

##
# @method				getValueFromHashMapWithKey
# @discussion			This function returns the value mapped to the specified key.
# @param $1				The hashmap to be queried.
# @param $2				The key of the mapped value.
# @return				The the value mapped to the specified key.
# @updated				2011-04-09
# @see					http://diggleby.com/create-keyvalue-pairs-in-bash/
# @see					http://stackoverflow.com/questions/918886/split-string-based-on-delimiter-in-bash
##
function getValueFromHashMapWithKey {
	local HashValue=""
	if [ "$1" != "" -a "$2" != "" ]; then
		local HashMap=$1
		local TIFS=$IFS
		IFS='|'
		for HashPair in $HashMap; do
			local HashKey=${HashPair%%:*}
			if [ "$2" = $HashKey ]; then
				HashValue=${HashPair#*:}
				break
			fi
		done
		IFS=$TIFS
	fi
	echo $HashValue
}

##
# @method				ucfirst
# @discussion			This function capitalize the first letter of a string.
# @param $1				The string to be capitalized.
# @return				The modified string.
# @updated				2011-04-08
# @see					http://www.linuxquestions.org/questions/programming-9/bash-scripting-capitalizing-first-letter-or-each-word-in-a-string-268182/)
##
function ucfirst {
	local DATA=$1
	local WORD=`echo -n "${DATA:0:1}" | tr "[:lower:]" "[:upper:]"`
	WORD=`echo -n "${WORD}${DATA:1}"`
	echo $WORD
}

##
# Gets a count of the number of passed arguments.
##
ARGCT=$#

##
# Tests for a properties file
##
if [ $ARGCT -ge 1 -a -e $1 ]; then
	##
	# Indicates that the BASH script is beginning to run.
	##
	echo "Generating files!"

	##
	# Loads data from the Java properties file (@see http://www.jeggu.com/2010/02/how-to-read-properties-using-bournebash.html)
	##
	. $1

    ##
    # Extract the name of the data source.
    ##
    DATA_SOURCE="${database%%.*}"

	##
	# Fetches an array of table names from the specified datatbase (@see http://mailliststock.wordpress.com/2007/03/01/sqlite-examples-with-bash-perl-and-python/)
	##
	tables=`sqlite3 $database "SELECT [name] FROM [sqlite_master] WHERE [type] = 'table' AND [name] NOT IN ('sqlite_sequence');"`

	##
	# Creates a model (i.e. an Active Records) for each table in the database.
	##
	for table in $tables; do
		##
		# Takes the table's name and ensures that it starts with a capital letter so that it can be used
		# for the model's class name.
		##
		CLASS_NAME=$(ucfirst ${table})

		##
		# Constructs the name for the class's ".h" file.
		##
		MODEL_H="$CLASS_NAME.h"

		##
		# Generates the informational comment block for the ".h".
		##
		echo "//" 1> $MODEL_H
		echo "//  $CLASS_NAME.h" 1>> $MODEL_H
		echo "//  $application" 1>> $MODEL_H
		echo "//" 1>> $MODEL_H
		echo "//  Created by $author on $DATE_CREATED." 1>> $MODEL_H
		echo "//  Copyright $YEAR $author. All rights reserved." 1>> $MODEL_H
		echo -e "//\n" 1>> $MODEL_H

		##
		# Generates the import statement for parent class.
		##
		echo -e "#import \"ZIMOrmModel.h\"\n" 1>> $MODEL_H
		
		##
		# Generates the documentation for the class.
		##
		echo "/*!" 1>> $MODEL_H
		echo " @class $CLASS_NAME" 1>> $MODEL_H
		echo " @discussion This class represents a record in the \"$table\" table." 1>> $MODEL_H
		echo " @updated $DATE_MODIFIED" 1>> $MODEL_H
		echo " */" 1>> $MODEL_H
		
		##
		# Generates the class's @interface declaration with opening brace.
		##
		echo "@interface $CLASS_NAME : ZIMOrmModel {" 1>> $MODEL_H
		
		##
		# Generates the @private declaration to limit the visibility of instance variables.
		##
		echo -e "\n\t@private" 1>> $MODEL_H

		##
		# Fetches an array with the column information.
		##
		ColumnInformation=`sqlite3 $database "PRAGMA table_info($table);"`

		##
		# Declares the arrays to store specific column information.
		##
		declare -a ColumnNames
		declare -a ColumnTypes
		declare -a PrimaryKey

		##
		# Initializes whether the primary key is autoincremented.
		##
		AUTOINCREMENTED="NO"
		let PKCOUNT=0

		##
		# Parses the column information by spliting on the "|" delimiter (@see http://stackoverflow.com/questions/918886/split-string-based-on-delimiter-in-bash)
		##		
		OIFS=$IFS
		IFS='|'
		let INDEX=0
		let COUNT=0
		CTYPE=""
		for Info in $ColumnInformation; do
			let POSITION=$INDEX%5
			if [ $POSITION -eq 1 ]; then # gets the column's name
				for token in ${RESERVED_TOKENS[@]}; do
					if [ "$Info" = "$token" ]; then
						echo "Error: Column '$Info' must be renamed, cannot be a reserved word."
						exit 1
					fi
				done
				ColumnNames[$COUNT]="$Info"
			elif [ $POSITION -eq 2 ]; then # gets the column's datatype
				CTYPE=`echo -n "${Info%%(*}" | tr "[:lower:]" "[:upper:]"`
				ColumnTypes[$COUNT]=`getValueFromHashMapWithKey "$DATATYPES" "$CTYPE"`
				if [ -z "${ColumnTypes[${COUNT}]}" ]; then
					echo "Error: Unknown datatype detected."
					exit 1
				fi
			elif [ $INDEX -gt 0 -a $POSITION -eq 0 ]; then # gets the column's primary key flag
				PrimaryKey[$COUNT]="${Info:0:1}" # ${string:position:length}
				if [ "${PrimaryKey[${COUNT}]}" = "1" ]; then
					if [ $PKCOUNT -eq 0 -a "$CTYPE" = "INTEGER" ]; then
						AUTOINCREMENTED="YES"
					else
						AUTOINCREMENTED="NO"
					fi
					let PKCOUNT=$PKCOUNT+1
				fi
				let COUNT=$COUNT+1
			fi
			let INDEX=$INDEX+1
		done
		IFS=$OIFS

		##
		# Generates the instance variables.
		##
		let INDEX=0
		while [ $INDEX -lt $COUNT ]; do
			echo -e "\t\t${ColumnTypes[${INDEX}]} *_${ColumnNames[${INDEX}]};" 1>> $MODEL_H
			let INDEX=$INDEX+1
		done

		##
		# Generates a closing brace.
		##
		echo -e "\n}\n" 1>> $MODEL_H
		
		##
		# Generates the @property declarations for each instance variable.
		##
		let INDEX=0
		while [ $INDEX -lt $COUNT ]; do
			echo "@property (strong, nonatomic) ${ColumnTypes[${INDEX}]} *${ColumnNames[${INDEX}]};" 1>> $MODEL_H
			let INDEX=$INDEX+1
		done
		
		##
		# Generates the @end declaration for the class's ".h".
		##
		echo -e "\n@end" 1>> $MODEL_H

		##
		# Constructs the name for the class's ".m" file.
		##
		MODEL_M="$CLASS_NAME.m"

		##
		# Generates the informational comment block for the ".m".
		##
		echo "//" 1> $MODEL_M
		echo "//  $CLASS_NAME.m" 1>> $MODEL_M
		echo "//  $application" 1>> $MODEL_M
		echo "//" 1>> $MODEL_M
		echo "//  Created by $author on $DATE_CREATED." 1>> $MODEL_M
		echo "//  Copyright $YEAR $author. All rights reserved." 1>> $MODEL_M
		echo -e "//\n" 1>> $MODEL_M

		##
		# Generates the import statement for ".h".
		##
		echo -e "#import \"$CLASS_NAME.h\"\n" 1>> $MODEL_M

		##
		# Generates the class's @implementation declaration.
		##
		echo -e "@implementation $CLASS_NAME\n" 1>> $MODEL_M

		##
		# Generates the @synthesize declaration for each column.
		##
		let INDEX=0
		while [ $INDEX -lt $COUNT ]; do
			echo "@synthesize ${ColumnNames[${INDEX}]} = _${ColumnNames[${INDEX}]};" 1>> $MODEL_M
			let INDEX=$INDEX+1
		done

		##
		# Generates the class's constructor method.
		##
		echo -e "\n- (id) init {" 1>> $MODEL_M
		echo -e "\tif ((self = [super init])) {" 1>> $MODEL_M
		echo -e "\t\t_saved = nil;" 1>> $MODEL_M
		echo -e "\t}" 1>> $MODEL_M
		echo -e "\treturn self;" 1>> $MODEL_M
		echo -e "}\n" 1>> $MODEL_M

		##
		# Generates a method to return the data source.
		##
		echo "+ (NSString *) dataSource {" 1>> $MODEL_M
		echo -e "\treturn @\"$DATA_SOURCE\";" 1>> $MODEL_M
		echo -e "}\n" 1>> $MODEL_M

		##
		# Generates a method to return the table's name.
		##
		echo "+ (NSString *) table {" 1>> $MODEL_M
		echo -e "\treturn @\"$table\";" 1>> $MODEL_M
		echo -e "}\n" 1>> $MODEL_M

		##
		# Generates the primary key.
		##
		echo "+ (NSArray *) primaryKey {" 1>> $MODEL_M
		let INDEX=$COUNT-1
		PKEY="nil"
		while [ $INDEX -ge 0 ]; do
			if [ "${PrimaryKey[${INDEX}]}" = "1" ]; then
				PKEY="@\"${ColumnNames[${INDEX}]}\", $PKEY"
			fi
			let INDEX=$INDEX-1
		done
		if [ "$PKEY" != "nil" ]; then
			echo -e "\treturn [NSArray arrayWithObjects: $PKEY];" 1>> $MODEL_M
		else
			echo -e "\treturn nil;" 1>> $MODEL_M
		fi
		echo -e "}\n" 1>> $MODEL_M

		##
		# Generates a method to return whether the table's primary key auto-increments.
		##
		echo "+ (BOOL) isAutoIncremented {" 1>> $MODEL_M
		echo -e "\treturn $AUTOINCREMENTED;" 1>> $MODEL_M
		echo -e "}\n" 1>> $MODEL_M

		##
		# Generates the @end declaration for the class's ".m".
		##
		echo "@end" 1>> $MODEL_M
	done

    ##
    # Constructs the name for the database's ".plist" file.
    ##
    PLIST="db.plist"

	##
	# Generates the PLIST configuration file for the database.
	##
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" 1> $PLIST
	echo "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">" 1>> $PLIST
	echo "<plist version=\"1.0\">" 1>> $PLIST
	echo -e "<dict>" 1>> $PLIST
	echo -e "\t<key>$DATA_SOURCE</key>" 1>> $PLIST
	echo -e "\t<dict>" 1>> $PLIST
	echo -e "\t\t<key>database</key>" 1>> $PLIST
	echo -e "\t\t<string>$database</string>" 1>> $PLIST
	echo -e "\t\t<key>privileges</key>" 1>> $PLIST
	echo -e "\t\t<array>" 1>> $PLIST
	echo -e "\t\t\t<string>SELECT</string>" 1>> $PLIST
	echo -e "\t\t\t<string>INSERT</string>" 1>> $PLIST
	echo -e "\t\t\t<string>UPDATE</string>" 1>> $PLIST
	echo -e "\t\t\t<string>DELETE</string>" 1>> $PLIST
	echo -e "\t\t</array>" 1>> $PLIST
	echo -e "\t\t<key>readonly</key>" 1>> $PLIST
	echo -e "\t\t<false/>" 1>> $PLIST
	echo -e "\t\t<key>type</key>" 1>> $PLIST
	echo -e "\t\t<string>SQLite</string>" 1>> $PLIST
	echo -e "\t</dict>" 1>> $PLIST
	echo -e "</dict>" 1>> $PLIST
	echo "</plist>" 1>> $PLIST

	##
	# Indicates that the BASH script is done.
	##
	echo "Done!"
else 
	##
	# Indicates that an error occurred when loading the Java properties file.
	##
	echo "Error: Unable to load the Java properties file."
	exit 1
fi

##
# Terminates the BASH script
##
exit 0
