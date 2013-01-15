/*
 * Copyright 2012 - 2013 Kulykov Oleh
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#import "OKJSONParserApplicationTests.h"
#import "JSONKit.h"
#include "OKJSON.h"
#import "MachTime.h"

@implementation OKJSONParserApplicationTests


- (void) testFile:(NSString *)filePath
{
	NSLog(@"\n\ntestFile: %@ \n\n", [filePath lastPathComponent]);
	NSData * data = [NSData dataWithContentsOfFile:filePath];
	
	NSDictionary * NSDict = [NSJSONSerialization JSONObjectWithData:data 
															  options:0
																error:nil];
	NSDictionary * JSONKitDict = [[JSONDecoder decoder] parseJSONData:data];
	NSDictionary * OKDict = [OKJSON parse:data withError:nil];
	
	if ( ![NSDict isEqualToDictionary:JSONKitDict] )
	{
		STFail(@"JSONDecoder incorrect parse result");
	}
	
	if ( ![NSDict isEqualToDictionary:OKDict] )
	{
		STFail(@"OKJSONParser incorrect parse result");
	}
	
	if ( ![JSONKitDict isEqualToDictionary:OKDict] )
	{
		STFail(@"Both results not equal");
	}
}

- (void) testParse
{
	[self testFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"test2" ofType:@"json"]];
	[self testFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"test1" ofType:@"json"]];
	[self testFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"test3" ofType:@"json"]];
	[self testFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"test4" ofType:@"json"]];
	[self testFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"test5" ofType:@"json"]];
	[self testFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"test6" ofType:@"json"]];
	[self testFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"test7" ofType:@"json"]];
	[self testFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"test8" ofType:@"json"]];
	[self testFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"test9" ofType:@"json"]];
	[self testFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"test10" ofType:@"json"]];
	[self testFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"test11" ofType:@"json"]];
}

@end
