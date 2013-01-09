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

#import "AppDelegate.h"
#import "ViewController.h"
#import "JSONKit.h"
#include "OKJSON.h"
#import "MachTime.h"

@implementation AppDelegate

- (void) test
{
	NSDictionary * d1 = nil;
	NSDictionary * d2 = nil;
	NSMutableDictionary * testDict = nil;
	
	testDict = [NSMutableDictionary dictionary];
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
	
	d1 = [[JSONDecoder decoder] parseJSONData:testData];
	d2 = [OKJSON parse:testData withError:nil];// OKJSONParserParse([testData bytes], [testData length], (void**)&error);
	if ( ![testDict isEqualToDictionary:d1] )
	{
		NSLog(@"JSONDecoder incorrect parse result");
	}
	
	if ( ![testDict isEqualToDictionary:d2] )
	{
		NSLog(@"OKJSONParser incorrect parse result");
	}
	
	if ( ![d1 isEqualToDictionary:d2] )
	{
		NSLog(@"Both results not equal");
	}
	
	NSString * path = [[NSBundle bundleForClass:[self class]] pathForResource:@"test1" ofType:@"json"];
	NSData * data = [NSData dataWithContentsOfFile:path];
	
	d1 = [[JSONDecoder decoder] parseJSONData:data];
	d2 = [OKJSON parse:data withError:nil];
	testDict = [NSJSONSerialization JSONObjectWithData:data 
											   options:0
												 error:nil];
	if ( ![testDict isEqualToDictionary:d1] )
	{
		NSLog(@"JSONDecoder incorrect parse result");
	}
	
	if ( ![testDict isEqualToDictionary:d2] )
	{
		NSLog(@"OKJSONParser incorrect parse result");
	}
	
	if ( ![d1 isEqualToDictionary:d2] )
	{
		NSLog(@"Both results not equal");
	}
	
	
	
	const int iterations = 1000;
	
	NSTimeInterval JSONKitTime = GetMachTime();
	for (int i = 0; i < iterations; i++) 
	{
		NSDictionary * dict = [[JSONDecoder decoder] parseJSONData:data];
		dict = nil;
	}
	JSONKitTime = GetMachTime() - JSONKitTime;
	
	
	NSTimeInterval OKTime = GetMachTime();
	for (int i = 0; i < iterations; i++) 
	{
		NSDictionary * dict = [OKJSON parse:data withError:nil]; // OKJSONParserParse([data bytes], [data length], 0);
		dict = nil;
	}
	OKTime = GetMachTime() - OKTime;
	
	NSTimeInterval NSTime = GetMachTime();
	for (int i = 0; i < iterations; i++) 
	{
		NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data 
															  options:0
																error:nil];
		dict = nil;
	}
	NSTime = GetMachTime() - NSTime;
	
	const double JSONKit_OK_Rate = JSONKitTime / OKTime;
	const double NS_OK_Rate = NSTime / OKTime;
	
	if (JSONKitTime < OKTime) 
	{
		NSLog(@"OKJSONParser is slower ");
	}
	
	NSString * mode = @"Mode: Release\n";
#ifdef DEBUG
	mode = @"Mode: Debug\n";
#endif
	
	UIDevice * currentDevice = [UIDevice currentDevice];
	NSString * deviceInfo = [NSString stringWithFormat:@"SystemName: %@\nSystemVersion: %@\nModel: %@",
							 [currentDevice systemName],
							 [currentDevice systemVersion],
							 [currentDevice model]];
	
	NSString * mess = [NSString stringWithFormat:@"SIMPLE APP %@\nDevice: %@\nIterations count: %i\nJSONKit: %f (sec)\nOK: %f (sec)\nNS: %f (sec)\nRate(JSONKit/OK): %f\nRate(NS/OK):%f ", mode, deviceInfo, iterations, JSONKitTime, OKTime, NSTime, JSONKit_OK_Rate, NS_OK_Rate];
	
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Speed test OKJSONParser" 
													 message:mess
													delegate:nil
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil];
	[alert show];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self test];
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
