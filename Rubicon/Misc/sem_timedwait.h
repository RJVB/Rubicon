//
//  sem_timedwait.h
//  Rubicon
//
//  Created by Galen Rhodes on 3/8/17.
//  Copyright (c) 2017 Project Galen. All rights reserved.
//

#ifndef sem_timedwait_h
#define sem_timedwait_h

#include <stdio.h>

#if defined(__cplusplus)
extern "C" {
#endif

int sem_timedwait(sem_t *sem, const struct timespec *abs_timeout);

#if defined(__cplusplus)
}
#endif

#endif /* sem_timedwait_h */
