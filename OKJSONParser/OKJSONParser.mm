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


#include "OKJSONParser.h"

#import <CoreFoundation/CoreFoundation.h>

#include <inttypes.h>
#include <stdlib.h>

#ifndef __has_feature
#define __has_feature(x) 0
#endif

#if __has_feature(objc_arc)
#error Use compiller key "-fno-objc-arc" for this source file
#endif


//#define CHAR_TYPE uint32_t
#define CHAR_TYPE uint16_t
//#define CHAR_TYPE char

#define CH(c) ((CHAR_TYPE)c)

//#define OBJ_TYPE_TYPE uint32_t
#define OBJ_TYPE_TYPE uint16_t

//#define O_DICT				0x00000001
//#define O_ARRAY				0x00000010
//#define O_STRING			0x00000100
//#define O_NUMBER			0x00001000
//#define O_IS_DICT_KEY 		0x00010000
//#define O_IS_DICT_VALUE 	0x00100000
//#define O_IS_ARRAY_ELEM 	0x01000000


#define O_DICT				(1)
#define O_ARRAY				(1<<1)
#define O_STRING			(1<<2)
#define O_NUMBER			(1<<3)
#define O_IS_DICT_KEY 		(1<<4)
#define O_IS_DICT_VALUE 	(1<<5)
#define O_IS_ARRAY_ELEM 	(1<<6)


struct _OKJSONParserStruct
{
	uint8_t * data;
	uint8_t * end;
	id * objects;
	OBJ_TYPE_TYPE * types;
	NSError ** error;
	
	uint32_t capacity;
	int32_t index;
	
} __attribute__((packed));

typedef struct _OKJSONParserStruct OKJSONParserStruct;


void __OKJSONParserFreeParserDataStruct(OKJSONParserStruct & p)
{
	if (p.objects) free(p.objects);
	p.objects = 0;
	
	if (p.types) free(p.types);
	p.types = 0;
}

void __OKJSONParserCleanAll(OKJSONParserStruct & p)
{
	if (p.index >= 0)
	{
		id rootObject = p.objects[0];
		if (rootObject) CFRelease(rootObject);
	}
	__OKJSONParserFreeParserDataStruct(p);
}

void * __OKJSONParserNewMem(const size_t size)
{
	void * m = 0;
	if (posix_memalign((void**)&m, 4, size) == 0) return m;
	return 0;
}

int __OKJSONParserIncCapacity(OKJSONParserStruct & p)
{
	const size_t newCapacity = p.capacity + 16;
	
	id * o = (id *)__OKJSONParserNewMem(newCapacity * sizeof(id));
	OBJ_TYPE_TYPE * t = (OBJ_TYPE_TYPE *)__OKJSONParserNewMem(newCapacity * sizeof(OBJ_TYPE_TYPE));
	
	if (o && t)
	{
		if (p.capacity)
		{
			memcpy(o, p.objects, sizeof(id) * p.capacity);
			memcpy(t, p.types, sizeof(OBJ_TYPE_TYPE) * p.capacity);
		}
		__OKJSONParserFreeParserDataStruct(p);
		p.objects = o;
		p.types = t;
		p.capacity = newCapacity;
		return 1;
	}
	else 
	{
		if (o) free(o);
		if (t) free(t);
	}
	return 0;
}

void __OKJSONParserError(OKJSONParserStruct & p, const char * errorString)
{
	if (p.error)
	{
		NSDictionary * userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithUTF8String:errorString] 
															  forKey:@"message"];
		*p.error = [NSError errorWithDomain:@"OKJSONParser" code:-1 userInfo:userInfo];
	}
}

void __OKJSONParserBeforeOutWithError(OKJSONParserStruct & p, const char * errorString)
{
	__OKJSONParserCleanAll(p);
	__OKJSONParserError(p, errorString);
}

#define IS_CHAR_START_OF_DIGIT(c) (c>=CH('0')&&c<=CH('9'))||c==CH('-')||c==CH('+')
#define IS_GIGIT_CHAR(c) (c>=CH('0')&&c<=CH('9'))||c==CH('-')||c==CH('+')||c==CH('.')||c==CH('e')||c==CH('E')

id __OKJSONParserTryNumber(OKJSONParserStruct & p)
{
	switch (*p.data) 
	{
		case CH('t'): /// true
			if (strncmp((const char *)p.data, "true", 4) == 0)
			{
				p.data += 4;
				const char v = 1; // BOOL <- is char type on non ARC mode
				return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberCharType, &v);
			} break;
		case CH('f'): /// false
			if (strncmp((const char *)p.data, "false", 5) == 0)
			{
				p.data += 5;
				const char v = 0; // BOOL <- is char type on non ARC mode
				return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberCharType, &v);
			} break;
		case CH('n'): /// null
			if (strncmp((const char *)p.data, "null", 4) == 0)
			{
				p.data += 4;
				return (id)kCFNull;// [NSNull null];
			} break;
		default: break; 
	}
	
	
	const char * start = (char *)p.data;
	const uint8_t * end = p.end;
	int isUnsigned = 1, isReal = 0, isDigitsPresent = 0;
	do 
	{
		const CHAR_TYPE c = *p.data;
		if ( IS_GIGIT_CHAR(c) )
		{
			if (c == CH('-')) isUnsigned = 0;
			else if (c == CH('.')) isReal = 1;
			else if (c >= CH('0') && c <= CH('9')) isDigitsPresent = 1;
		}
		else
		{
			if (isDigitsPresent) break;
			else return nil;
		}	
	} while (++p.data <= end);
	
	if (isReal)
	{
		char * endConvertion = 0;
		const double v = strtod(start, &endConvertion);
		if (endConvertion) p.data = (uint8_t *)--endConvertion;
		return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &v);
	}
	else if (isUnsigned)
	{
		char * endConvertion = 0;
		//const unsigned long long v = strtoull(start, &endConvertion, 10);
		const long long v = strtoull(start, &endConvertion, 10);
		if (endConvertion) p.data = (uint8_t *)--endConvertion;
		//return [[NSNumber alloc] initWithUnsignedLongLong:v];
		return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberLongLongType, &v);
	}
	else
	{
		char * endConvertion = 0;
		const long long v = strtoll(start, &endConvertion, 10);
		if (endConvertion) p.data = (uint8_t *)--endConvertion;
		return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberLongLongType, &v);
	}
	return nil;
}

void __OKJSONParserParseReplacementString(const uint8_t * d, uint32_t len, NSString ** resString)
{
	UInt8 * n = (UInt8 *)malloc(len + 1);
	if (n) 
	{
		const UInt8 * sn = n;
		CHAR_TYPE prev = 0;
		CHAR_TYPE curr = *d;
		while (len--) 
		{
			switch (curr) 
			{
				case CH('\"'): if (prev == CH('\\')) { *--n = '\"'; n++; } else *n++ = *d; break;
				case CH('\\'): if (prev == CH('\\')) { *--n = '\\'; n++; } else *n++ = *d; break;
				case CH('/'): if (prev == CH('\\')) { *--n = '/'; n++; } else *n++ = *d; break;
				case CH('b'): if (prev == CH('\\')) { *--n = '\b'; n++; } else *n++ = *d; break;
				case CH('f'): if (prev == CH('\\')) { *--n = '\f'; n++; } else *n++ = *d; break;
				case CH('n'): if (prev == CH('\\')) { *--n = '\n'; n++; } else *n++ = *d; break;
				case CH('r'): if (prev == CH('\\')) { *--n = '\r'; n++; } else *n++ = *d; break;
				case CH('t'): if (prev == CH('\\')) { *--n = '\t'; n++; } else *n++ = *d; break;
				case CH('u'): 
					break;
				default: *n++ = *d; break;
			}			
			prev = curr;
			curr = *++d;
		}
		CFStringRef s = CFStringCreateWithBytesNoCopy(kCFAllocatorDefault,
													  (const UInt8 *)sn, 
													  ((const uint8_t *)n - (const uint8_t *)sn), 
													  kCFStringEncodingUTF8, 
													  true, 
													  kCFAllocatorDefault);
		if (s) *resString = (NSString *)s;
		else free(n);
	}
}

void __OKJSONParserParseString(OKJSONParserStruct & p, NSString ** resString)
{
	int isHasReplacement = 0;
	const uint8_t * start = p.data;
	const uint8_t * data = start;
	const uint8_t * end = p.end;
	CHAR_TYPE prev = 0;
	do 
	{
		const CHAR_TYPE curr = *data;
		if (prev == CH('\\')) 
		{
			switch (curr) 
			{
				case CH('\"'):
				case CH('\\'):
				case CH('/'): 
				case CH('b'): 
				case CH('f'): 
				case CH('n'): 
				case CH('r'): 
				case CH('t'): 
				case CH('u'): isHasReplacement = 1; break;
				default: break;
			}
		}
		if (curr == CH('\"') && prev != CH('\\')) break;
		prev = curr;
	} while (++data <= end);
	
	p.data = (uint8_t *)data;
	
	if (isHasReplacement) __OKJSONParserParseReplacementString(start, (data - start), resString);
	else *resString = (NSString *)CFStringCreateWithBytes(kCFAllocatorDefault, 
														  (const UInt8 *)start, 
														  (p.data - start), 
														  kCFStringEncodingUTF8, 
														  true);
}

#define IS_CONTAINER(o) ((o&O_DICT)||(o&O_ARRAY)) 

int __OKJSONParserAddObject(OKJSONParserStruct & p, id obj, const OBJ_TYPE_TYPE type)
{	
	const int addIndex = p.index + 1;
	
	if (addIndex >= p.capacity) if (!__OKJSONParserIncCapacity(p)) return 0;
	
	if (addIndex == 0)
	{
		p.index = addIndex; p.objects[addIndex] = obj; p.types[addIndex] = type;
		return 1;
	}
	else 
	{
		const int currIndex = p.index;
		if ( p.types[currIndex] & O_ARRAY )
		{
			CFArrayAppendValue((CFMutableArrayRef)p.objects[currIndex], (const void *)obj);
			CFRelease(obj);
			if ( IS_CONTAINER(type) )
			{
				p.index = addIndex; p.objects[addIndex] = obj; p.types[addIndex] = (type | O_IS_ARRAY_ELEM);
			}
			return 1;
		}
		else if ( p.types[currIndex] & O_DICT )
		{
			if ( IS_CONTAINER(type) ) return 0;
			else 
			{
				p.index = addIndex; p.objects[addIndex] = obj; p.types[addIndex] = (type | O_IS_DICT_KEY);
			}
			return 1;
		}
		
		const int prevIndex = currIndex - 1;
		if (prevIndex >= 0)
			if ( p.types[prevIndex] & O_DICT )
			{
				CFDictionarySetValue((CFMutableDictionaryRef)p.objects[prevIndex], (const void *)p.objects[currIndex], (const void *)obj);
				CFRelease(obj);
				CFRelease(p.objects[currIndex]);
				if ( IS_CONTAINER(type) )
				{
					p.index = addIndex; p.objects[addIndex] = obj; p.types[addIndex] = (type | O_IS_DICT_VALUE);
				}
				else 
				{
					p.index = prevIndex;
				}
				return 1;
			}
	}
	
	return 0;
}

void __OKJSONParserEndedContainer(OKJSONParserStruct & p)
{
	const int currIndex = p.index;
	if (currIndex > 0)
	{
		const OBJ_TYPE_TYPE currType = p.types[currIndex];
		if (currType & O_IS_ARRAY_ELEM)	p.index = (currIndex - 1);
		else if (currType & O_IS_DICT_VALUE) p.index = (currIndex - 2);
	}
}

id OKJSONParserParse(const uint8_t * inData, const uint32_t inDataLength, void ** error)
{	
	OKJSONParserStruct p = { 0 };
	p.index = -1;
	p.error = (NSError **)error;
	p.data = const_cast<uint8_t *>(inData);
	const uint8_t * end = p.end = p.data + inDataLength;
	
	do 
	{
		const CHAR_TYPE c = *p.data;
		
		switch (c) 
		{
			case CH('{'):
			{
				id newDict = (id)CFDictionaryCreateMutable(kCFAllocatorDefault, 
														   4,
														   &kCFTypeDictionaryKeyCallBacks,
														   &kCFTypeDictionaryValueCallBacks);
				if (newDict)
				{
					if (!__OKJSONParserAddObject(p, newDict, O_DICT)) 
					{
						__OKJSONParserBeforeOutWithError(p, "Can't store JSON Dictionary object"); 
						return nil;
					}
				}
				else 
				{ 
					__OKJSONParserBeforeOutWithError(p, "Can't initialize JSON Dictionary object"); 
					return nil; 
				}
			} break;
				
			case CH('}'): //__OKJSONParserEndedContainer(p); break;
			case CH(']'): __OKJSONParserEndedContainer(p); break;
				
			case CH('['):
			{
				id newArray = (id)CFArrayCreateMutable(kCFAllocatorDefault, 4, &kCFTypeArrayCallBacks);
				if (newArray) 
				{
					if (!__OKJSONParserAddObject(p, newArray , O_ARRAY))
					{
						__OKJSONParserBeforeOutWithError(p, "Can't store JSON Array object"); 
						return nil;
					}
				}
				else 
				{
					__OKJSONParserBeforeOutWithError(p, "Can't initialize JSON Array object"); 
					return nil; 
				}
			} break;
				
			case CH('\"'):	
			{
				p.data++;
				NSString * newString = nil;
				__OKJSONParserParseString(p, &newString);
				if (newString) 
				{
					if (!__OKJSONParserAddObject(p, newString, O_STRING))
					{
						__OKJSONParserBeforeOutWithError(p, "Can't store JSON String object");
						return nil;
					}
				}
				else 
				{
					__OKJSONParserBeforeOutWithError(p, "Can't initialize JSON String object"); 
					return nil; 
				}
			} break;
				
//			case 0:	
//			{
//				id r = IS_CONTAINER(p.types[0]) ? p.objects[0] : nil;
//				__OKJSONParserFreeParserDataStruct(p);
//				return r;
//			}
//				break;
		 
			default:
			{
				if (IS_CHAR_START_OF_DIGIT(c) || c == CH('t') || c == CH('f') || c == CH('n'))
				{
					id newNumber = __OKJSONParserTryNumber(p);
					if (newNumber) 
					{
						if (!__OKJSONParserAddObject(p, newNumber, O_NUMBER))
						{
							__OKJSONParserBeforeOutWithError(p, "Can't initialize JSON Number object");
							return nil;
						}
					}
				}
			} break;
		}
	} while (++p.data <= end);
	
	if (p.index == 0 && IS_CONTAINER(p.types[0]))
	{
		id r = p.objects[0];
		__OKJSONParserFreeParserDataStruct(p);
		return r;
	}
	
	__OKJSONParserBeforeOutWithError(p, "Parser logic incorrect");
	
	return nil;
}


@implementation OKJSONParser

+ (id) parseData:(NSData *)data error:(NSError **)error
{
	const uint8_t * dataBytes = (const uint8_t *)[data bytes];
	const uint32_t dataLength = [data length];
	if (dataBytes && dataLength) 
	{
		return [OKJSONParserParse(dataBytes, dataLength, (void **)error) autorelease];
	}
	return nil;
}

@end



