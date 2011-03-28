# Objective-C SQL Query Builder

This repository contains two sets of Objective-C based classes that handle a SQLite database. The DAO folder contains
a class that easily manages the database connection.  The SQL folder contains a collection of SQL builder classes that
can be used to construct well-formed SQL statements for SQLite via a plethora of convenience methods similar to those
found in LINQ.

All classes were designed to be used in iPhone/iOS applications.

## Motivation

The goal is to make these classes the "de facto" standard for communicating with SQLite databases on iPhone/iOS devices.

After looking at other Objective-C SQLite projects, it was obvious that there was a need for an Objective-C library that
offered more than just a set of wrapper classes.  It was even more apparent that classes needed to be written very cleanly
and with clear naming conventions similar to those in LINQ.  With the abundance of third-party libraries for Objective-C,
developers are craving libraries that are simple to learn and are intuitive.  Therefore, the classes in this repository
are written with these observations in mind.

## Features

The following is a short-list of some the features:

* Implements a very simple, but powerful, Data Access Object (DAO).
* Has a large collection of SQL builder classes with methods that mimics their SQL equivalent.
* SQL builder classes help ensure that SQL is well-formed.
* Execute an SQL statement or query using an SQL statement with one line of code.
* Good performance.
* Classes are easily extendable.

## Getting Started

Using these class in an Xcode project is easy to do.  Here is how:

1. Download the source code via Github as a tarball (i.e. .tar.gz).
2. Navigate to the tarball in Finder.
3. Unachieve the tarball by double-clicking it in a Finder window.
4. Open an Xcode project.
5. Right-click on the "Classes" folder and "Add >> Existing Files...".
6. Highlight the files, then click "Add".
7. Check "Copy items into destination group's folder (if needed)".
8. Select "Default" for the "Reference Type".
9. Choose "Recursively create groups for any added folders".
10. Click "Add".

### Required Frameworks

To use these classes in an Xcode project, add the following framework:

* libsqlite3.dylib

### Documentation

All classes are heavily documented.  You can get familiar with each class by simply opening it respective ".h" file.
You can also find more information on this repository's Wiki.

### Examples

Checkout this repository's Wiki for a handful of examples.

## Reporting Bugs & Making Recommendations

Help debug the Objective-C classes in repository by reporting any bugs.  The more detailed the report the better.  If
you have a bug-fix or a unit-test, please send a message to this repository's inbox.

Likewise, if you would like to make a recommendation on how to improve these classes, take the time to send a message
so that it can be considered for an upcoming release.  This will help keep the repository active.

## License (Apache v2.0)

Copyright 2011 Ziminji

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at:

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
