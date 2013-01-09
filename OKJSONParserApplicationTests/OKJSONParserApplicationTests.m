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

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void) testParse
{
	NSDictionary * d1 = nil;
	NSDictionary * d2 = nil;
	NSMutableDictionary * testDict = nil;
	
	testDict = [NSMutableDictionary dictionary];
	
	NSString * string1 = @"S\"tring";
	
	[testDict setObject:string1 forKey:@"string1"];
	
	
	[testDict setObject:@"q\"q" forKey:@"key6"];
	[testDict setObject:@"" forKey:@"emptyString"];
	NSArray * arr1 = [NSArray arrayWithObjects:@"arrElem1", @"arrElem2", nil];
	[testDict setObject:arr1 forKey:@"arr1"];
	[testDict setObject:@"value" forKey:@"key1"];
	[testDict setObject:[NSNumber numberWithLongLong:-3] forKey:@"intKey"];
	[testDict setObject:[NSNumber numberWithBool:YES] forKey:@"true1Key"];
	[testDict setObject:[NSNumber numberWithBool:NO] forKey:@"falseKey"];
	[testDict setObject:[NSNull null] forKey:@"nullKey"];
	NSData * testData = [NSJSONSerialization dataWithJSONObject:testDict 
														options:0
														  error:nil];
	NSString * dataString = [[NSString alloc] initWithUTF8String:[testData bytes]];
	NSLog(@"dataString: %@", dataString);
	
	string1 = [testDict objectForKey:@"string1"];
	
	d1 = [[JSONDecoder decoder] parseJSONData:testData];
	d2 = [OKJSON parse:testData withError:nil]; // OKJSONParserParse([testData bytes], [testData length], 0);
	
	string1 = [d2  objectForKey:@"string1"];
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
	
	NSString * path = [[NSBundle bundleForClass:[self class]] pathForResource:@"test1" ofType:@"json"];
	NSData * data = [NSData dataWithContentsOfFile:path];
	
	d1 = [[JSONDecoder decoder] parseJSONData:data];
	d2 = [OKJSON parse:data withError:nil]; // OKJSONParserParse([data bytes], [data length], 0);
	testDict = [NSJSONSerialization JSONObjectWithData:data 
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
		NSDictionary * dict = [OKJSON parse:data withError:nil];// OKJSONParserParse([data bytes], [data length], 0);
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

@end
