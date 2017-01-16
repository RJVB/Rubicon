/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGTimeSpec.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/14/17 5:49 PM
 * DESCRIPTION:
 *
 * Copyright © 2017 Project Galen. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *******************************************************************************/

#import "PGTimeSpec.h"

@implementation PGTimeSpec {
		TimeSpec _timeSpec;
	}

	-(instancetype)init {
		self = [super init];

		if(self) {
			TimeVal timeVal;
			gettimeofday(&timeVal, NULL);
			_timeSpec.tv_sec  = timeVal.tv_sec;
			_timeSpec.tv_nsec = (timeVal.tv_usec * 1000);
		}

		return self;
	}

	-(instancetype)initWithSeconds:(NSInteger)seconds andNanos:(NSInteger)nanos {
		self = [super init];

		if(self) {
			if(seconds < 0 || nanos < 0 || nanos >= PG_NANOS_PER_SECOND) {
				NSString *reason = (seconds < 0 ? @"Seconds < 0" : @"Nanoseconds not in range 0 <= ns <= 999,999,999");
				@throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
			}

			NSInteger nanosOver = (nanos / (NSInteger)PG_NANOS_PER_SECOND);
			_timeSpec.tv_sec  = (seconds + nanosOver);
			_timeSpec.tv_nsec = (nanos - (nanosOver * (NSInteger)PG_NANOS_PER_SECOND));
		}

		return self;
	}

	-(instancetype)initWithTimeVal:(PTimeVal)timeVal {
		return (self = [self initWithSeconds:timeVal->tv_sec andNanos:timeVal->tv_usec * (NSInteger)PG_NANOS_PER_MICRO]);
	}

	-(instancetype)initWithTimeSpec:(const PTimeSpec)timeSpec; {
		return (self = [self initWithSeconds:timeSpec->tv_sec andNanos:timeSpec->tv_nsec]);
	}

	+(instancetype)timeSpecWithCurrentTime {
		return [[self alloc] init];
	}

	+(instancetype)timeSpecWithSeconds:(NSInteger)seconds andNanos:(NSInteger)nanos {
		return [[self alloc] initWithSeconds:seconds andNanos:nanos];
	}

	+(instancetype)timeSpecWithTimeVal:(PTimeVal)timeVal {
		return [[self alloc] initWithTimeVal:timeVal];
	}

	+(instancetype)timeSpecWithTimeSpec:(const PTimeSpec)timeSpec {
		return [[self alloc] initWithTimeSpec:timeSpec];
	}

	-(NSLong)years {
		return (self.seconds / PG_SECONDS_PER_YEAR);
	}

	-(NSLong)days {
		return (self.seconds / PG_SECONDS_PER_DAY);
	}

	-(NSLong)hours {
		return (self.seconds / PG_SECONDS_PER_HOUR);
	}

	-(NSLong)minutes {
		return (self.seconds / PG_SECONDS_PER_MINUTE);
	}

	-(NSLong)seconds {
		return _timeSpec.tv_sec;
	}

	-(NSLong)milliseconds {
		return (self.nanoseconds / PG_NANOS_PER_MILLI);
	}

	-(NSLong)microseconds {
		return (self.nanoseconds / PG_NANOS_PER_MICRO);
	}

	-(NSLong)nanoseconds {
		return ((_timeSpec.tv_sec * PG_NANOS_PER_SECOND) + _timeSpec.tv_nsec);
	}

@end
