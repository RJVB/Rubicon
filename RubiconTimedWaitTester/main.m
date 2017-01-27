//
//  main.m
//  RubiconTimedWaitTester
//
//  Created by Galen Rhodes on 1/26/17.
//  Copyright © 2017 Project Galen. All rights reserved.
//

#import <Rubicon/Rubicon.h>
#import <pthread.h>

#define SEM_WAIT_TIME 10

void *threadRunner(void *ptr) {
	PGSemaphore *semaphore = (__bridge_transfer PGSemaphore *)ptr;
	PGTimeSpec  *absTime   = [PGTimeSpec timeSpecWithFutureSeconds:SEM_WAIT_TIME andNanos:0];

	NSLog(@"Waiting for semaphore for %@ seconds...", @(SEM_WAIT_TIME));
	BOOL success = [semaphore timedWait:absTime];

	NSLog(@"Status of timed wait: %@", (success ? @"YES" : @"NO"));
	return (void *)(long)success;
}

int main(int argc, const char *argv[]) {
	@autoreleasepool {
		PGSemaphore *semaphore = [[PGSemaphore alloc] initWithSemaphoreName:@"galen" value:1];
		pthread_t   semThread;
		void        *result;

		[semaphore wait];
		NSLog(@"Results of tryWait: %@", ([semaphore tryWait] ? @"YES" : @"NO"));

		pthread_create(&semThread, NULL, threadRunner, (__bridge_retained void *)semaphore);
		NSLog(@"Waiting for thread to end.");
		pthread_join(semThread, &result);
		NSLog(@"Done with results: %@", (((long)result) ? @"YES" : @"NO"));
	}

	return 0;
}
