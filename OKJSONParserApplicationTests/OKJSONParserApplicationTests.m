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
	NSData * data = [NSData dataWithContentsOfFile:filePath];
	
	NSDictionary * testDict = [NSJSONSerialization JSONObjectWithData:data 
															  options:0
																error:nil];
	NSDictionary * d1 = [[JSONDecoder decoder] parseJSONData:data];
	NSDictionary * d2 = [OKJSON parse:data withError:nil];
	
	if ( ![testDict isEqualToDictionary:d1] )
	{
		STFail(@"JSONDecoder incorrect parse result");
	}
	
	if ( ![testDict isEqualToDictionary:d2] )
	{
		STFail(@"OKJSONParser incorrect parse result");
	}
	
	if ( ![d1 isEqualToDictionary:d2] )
	{
		STFail(@"Both results not equal");
	}
}

- (void) testTime
{
	NSString * path = [[NSBundle bundleForClass:[self class]] pathForResource:@"test2" ofType:@"json"];
	NSData * data = [NSData dataWithContentsOfFile:path];
	
	NSDictionary * d1 = [[JSONDecoder decoder] parseJSONData:data];
	NSDictionary *d2 = [OKJSON parse:data withError:nil];
	NSDictionary *	testDict = [NSJSONSerialization JSONObjectWithData:data 
											   options:0
												 error:nil];
	if ( ![testDict isEqualToDictionary:d1] )
	{
		STFail(@"JSONDecoder incorrect parse result");
	}
	
	if ( ![testDict isEqualToDictionary:d2] )
	{
		STFail(@"OKJSONParser incorrect parse result");
	}
	
	if ( ![d1 isEqualToDictionary:d2] )
	{
		STFail(@"Both results not equal");
	}
	
	
	const int times = 5000;
	
	NSTimeInterval time1 = GetMachTime();
	for (int i = 0; i < times; i++) 
	{
		NSDictionary * dict = [[JSONDecoder decoder] parseJSONData:data];
		dict = nil;
	}
	time1 = GetMachTime() - time1;
	
	
	NSTimeInterval time2 = GetMachTime();
	for (int i = 0; i < times; i++) 
	{
		NSDictionary * dict = [OKJSON parse:data withError:nil];
		dict = nil;
	}
	time2 = GetMachTime() - time2;
	
	NSTimeInterval time0 = GetMachTime();
	for (int i = 0; i < times; i++) 
	{
		NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data 
															  options:0
																error:nil];
		dict = nil;
	}
	time0 = GetMachTime() - time0;
	
	
	const double fasterRate1 = time1 / time2;
	const double fasterRate2 = time0 / time2;
	
	if (time1 < time2) 
	{
		STFail(@"OKJSONParser is slower ");
	}
	NSLog(@"\n\n\n\nTEST_APP\nJSONDec:%f  \nOKJSONP:%f   \nNSJSONS:%f  \nFasterRate1:%f  \nFasterRate2:%f \n\n\n", time1, time2, time0, fasterRate1, fasterRate2);
}

- (void) testParse
{
	[self testFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"test2" ofType:@"json"]];
	[self testFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"test1" ofType:@"json"]];
}

@end
