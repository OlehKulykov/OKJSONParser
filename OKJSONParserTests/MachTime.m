/*
 *   Copyright 2012 - 2013 Kulykov Oleh
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */


#import "MachTime.h"

#ifndef NO_MACHTIME_CATEGORY_OK

#include <inttypes.h>
#include <mach/mach_time.h>

typedef struct __machTimeStruct
{
	uint64_t absoluteAppStartTime;
	uint64_t absoluteLastCallTime;
	long double nanoSecond;
} __MachTimeStruct;

static void __InitMachTimeStruct(__MachTimeStruct * timeStruct)
{
	mach_timebase_info_data_t info = { 0 };
	if (mach_timebase_info(&info) == KERN_SUCCESS && info.denom)
	{
		timeStruct->absoluteAppStartTime = mach_absolute_time();
		timeStruct->absoluteLastCallTime = timeStruct->absoluteAppStartTime;
		timeStruct->nanoSecond = 1e-9 * ((long double)info.numer) / ((long double)info.denom);
	}
}

NSTimeInterval GetMachTime()
{
	static __MachTimeStruct timeStruct = { 0 };
	if ( !timeStruct.absoluteAppStartTime )
	{
		__InitMachTimeStruct(&timeStruct);
	}
	return ((long double)(mach_absolute_time() - timeStruct.absoluteAppStartTime) * timeStruct.nanoSecond);
}

#endif

