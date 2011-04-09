#!/bin/bash

##
# Copyright 2011 Ziminji
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
# Before running this script, configure the associated Java properties file.
#
# To run this BASH script, use the following commands:
# 	username$ chmod +x ZIMGenModel.sh 
# 	username$ ./ZIMGenModel.sh ZIMGenModel.properties
##

##
# Defines date related constants.
##
declare -r DATE_CREATED=$(date +%m/%d/%y)
declare -r YEAR=$(date +%Y)
declare -r DATE_MODIFIED=$(date +%F)

##
# Defines the hashmap for translating columns.
##
declare -r DATATYPES="BIGINT:NSNumber|BOOLEAN:NSNumber|INT:NSNumber|INT2:NSNumber|INT8:NSNumber|INTEGER:NSNumber|MEDIUMINT:NSNumber|SMALLINT:NSNumber|TINYINT:NSNumber|UNSIGNED BIG INT:NSNumber|DECIMAL:NSNumber|DOUBLE:NSNumber|DOUBLE PRECISION:NSNumber|FLOAT:NSNumber|NUMERIC:NSNumber|REAL:NSNumber|CHAR:NSString|CHARACTER:NSString|CLOB:NSString|NATIONAL VARYING CHARACTER:NSString|NATIVE CHARACTER:NSString|NCHAR:NSString|NVARCHAR:NSString|TEXT:NSString|VARCHAR:NSString|VARIANT:NSString|VARYING CHARACTER:NSString|BLOB:NSData|NULL:NSNull|DATE:NSDate|DATETIME:NSDate|TIMESTAMP:NSDate"

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
		local HashMap=$1 #$(echo "$1" | tr "|" "\n")
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
	# Loads data from the Java properties file (@see http://www.jeggu.com/2010/02/how-to-read-properties-using-bournebash.html)
	##
	. $1

	##
	# Fetches an array of table names from the specified datatbase (@see http://mailliststock.wordpress.com/2007/03/01/sqlite-examples-with-bash-perl-and-python/)
	##
	tables=`sqlite3 $database "SELECT tbl_name FROM sqlite_master WHERE type = 'table';"`

	##
	# Creates a model (i.e. an Active Records) for each table in the database.
	##
	for table in $tables; do
		##
		# Takes the table's name and ensures that starts with a capital letter so that it can be used
		# for the model's class name.
		##
		CLASS_NAME=$(ucfirst ${table})

		##
		# Constructs the file name for the class's ".h".
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
		echo " @discussion This class represents an SQL statements." 1>> $MODEL_H
		echo " @updated $DATE_MODIFIED" 1>> $MODEL_H
		echo " */" 1>> $MODEL_H
		
		##
		# Generates the class's @interface declaration with opening brace.
		##
		echo "@interface $CLASS_NAME : ZIMOrmModel {" 1>> $MODEL_H
		
		##
		# Generates the @protected declaration to limit the visibility of instance variables.
		##
		echo -e "\n\t@protected" 1>> $MODEL_H

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
				ColumnNames[$COUNT]="$Info"
			elif [ $POSITION -eq 2 ]; then # gets the column's datatype
				CTYPE=`echo -n "${Info%%(*}" | tr "[:lower:]" "[:upper:]"`
				ColumnTypes[$COUNT]=`getValueFromHashMapWithKey "$DATATYPES" "$CTYPE"`
				if [ "$ColumnTypes[$COUNT]" = "" ]; then
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
			echo -e "\t\t${ColumnTypes[${INDEX}]} *${ColumnNames[${INDEX}]};" 1>> $MODEL_H
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
			echo "@property (nonatomic, retain) ${ColumnTypes[${INDEX}]} *${ColumnNames[${INDEX}]};" 1>> $MODEL_H
			let INDEX=$INDEX+1
		done
		
		##
		# Generates the @end declaration for the class's ".h".
		##
		echo -e "\n@end" 1>> $MODEL_H

		##
		# Constructs the file name for the class's ".m"
		##
		MODEL_M="$CLASS_NAME.m"

		##
		# Generates the informational comment block for the ".h"
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
		# Generates the class's constructor method with opening braces.
		##
		echo "- (id) init {" 1>> $MODEL_M
		echo -e "\tif (self = [super init]) {" 1>> $MODEL_M

		##
		# Generates the primary key.
		##
		let INDEX=0
		PKEY=""
		while [ $INDEX -lt $COUNT ]; do
			if [ "${PrimaryKey[${INDEX}]}" = "1" ]; then
				if [ "$PKEY" != "" ]; then
					PKEY="$PKEY, @\"${ColumnNames[${INDEX}]}\""
				else
					PKEY="@\"${ColumnNames[${INDEX}]}\""
				fi
			fi
			let INDEX=$INDEX+1
		done
		if [ "$PKEY" != "" ]; then
			echo -e "\t\t_primaryKey = [NSSet setWithObject: $PKEY];" 1>> $MODEL_M
			
		else
			echo -e "\t\t_primaryKey = nil;" 1>> $MODEL_M
		fi
		echo -e "\t\t_autoIncremented = $AUTOINCREMENTED;" 1>> $MODEL_M
		
		##
		# Generates the class's constructor method with closing braces.
		##
		echo -e "\t}" 1>> $MODEL_M
		echo -e "\treturn self;" 1>> $MODEL_M
		echo -e "}\n" 1>> $MODEL_M

		##
		# Generates the class's destructor method.
		##
		echo "- (void) dealloc {" 1>> $MODEL_M
		echo -e "\t[super dealloc];" 1>> $MODEL_M
		echo -e "}\n" 1>> $MODEL_M

		##
		# Generates a method to return the data source.
		##
		echo "+ (NSString *) dataSource {" 1>> $MODEL_M
		echo -e "\treturn @\"$database\";" 1>> $MODEL_M
		echo -e "}\n" 1>> $MODEL_M

		##
		# Generates a method to return the table's name.
		##
		echo "+ (NSString *) table {" 1>> $MODEL_M
		echo -e "\treturn @\"$table\";" 1>> $MODEL_M
		echo -e "}\n" 1>> $MODEL_M
		
		##
		# Generates the @end declaration for the class's ".m".
		##
		echo "@end" 1>> $MODEL_M
	done
else 
	echo "Error: Unable to load the Java properties file."
	exit 1
fi

##
# Terminates the BASH script
##
exit 0
