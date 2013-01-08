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


#import <Foundation/Foundation.h>

@interface OKJSONParser : NSObject

+ (id) parseData:(NSData *)data error:(NSError **)error;

@end

/*
#ifndef __OKJSONPARSER_H__
#define __OKJSONPARSER_H__

/// Return value is NOT autoreleased, you need to release manualy or 
/// use ARC mode.
/// 'inData' - NOT NULL !!!, but JSON text string.
/// 'error' - is pointer to 'NSError *' variable.
id OKJSONParserParse(const uint8_t * inData, const uint32_t inDataLength, void ** error);


#endif
 
*/
 
