# Rubicon

Rubicon is an Objective-C library designed to speed cross-platform development by
filling in the missing pieces between the official Apple version of it's Foundation 
classes and the [GNUstep](http://www.gnustep.org) version of the Foundation classes.

### Linux vs macOS

Rubicon also attempts to smooth out some of the more glaring differences between
the Linux operating system and the macOS operating system such as the former's
glaring omission of the [int clock_gettime(clockid_t clk_id, struct timespec *tp);](https://linux.die.net/man/3/clock_gettime)
function in versions prior to 10.12 (_macOS Sierra_).

### Additions

Rubicon also provides some of my own additions, (defines, functions, classes,
protocols,and categories) to make development easier in general even if it's not
cross-platform. For example, Rubicon includes an implementation of a full
red-black binary tree that is independent of the NSDictionary and NSSet classes.
This allows you to use a super fast binary tree in your own classes without the
overhead of the NSDictionary and NSSet collection classes.

## PGSimpleBuffer and PGCString

Many times in writing Objective-C programs that call C libraries there is a need to
allocate memory buffers and C style strings. This is not really a problem except for
the often ugly code involved in making sure any temporary buffers or C strings get
deallocated when their time is done.
[ARC only covers Objective-C objects](https://developer.apple.com/library/archive/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html)
and not memory allocated for non-object memory such as byte buffers and C strings.
So, I created two helper classes for this.

**PGSimpleBuffer** is an Objective-C wrapper around a buffer created with the standard
[void *malloc(size_t)](http://www.manpagez.com/man/3/malloc/) function. You simply specify
the size of the buffer you want to create and then when the instance of that class is
deallocated by ARC the buffer will be freed as well. You can obtain a pointer to the
underlying buffer with the instance property [void *buffer](https://github.com/GalenRhodes/Rubicon/blob/master/Rubicon/Buffers/PGSimpleBuffer.h).

**PGCString** is an Objective-C wrapper around a copy of a C string. Like the *PGSimpleBuffer*
class, when the surrounding Objective-C instance is deallocated, the C string is
deallocated as well. This class came into being because of the lack of clarity on
just how long the pointer returned by _NSString_'s
[UTF8String](https://developer.apple.com/documentation/foundation/nsstring/1411189-utf8string?language=objc)
is valid for. The only safe way to make sure the pointer remains valid for as long as
you need it is to make a copy of it with
[char *strdup(const char *)](http://www.manpagez.com/man/3/strdup/). And again your
back to having to make sure the copy is deallocated properly. Hence you now have
[PGCString](https://github.com/GalenRhodes/Rubicon/blob/master/Rubicon/Misc/PGCString.h)
to make your life easier.  

## PGSemaphore

**PGSemaphore** is an Objective-C class that provides a wrapper around the
semaphore functions provided in the POSIX pthreads library. Additionally it
provides a handy implementation of the [sem_timedwait](http://man7.org/linux/man-pages/man3/sem_wait.3.html)
function that is found in most newer Linux versions. *see
[sem_timedwait.c](Rubicon/Concurrency/Locks/sem_timedwait.c)*

## sem_timedwait

The function **sem_timedwait** exists in most Linux implementations but because
it is a rather new addition to the POSIX pthreads specification it does not exists
everywhere and macOS is no exception. However, because it's a very handy function,
[Keith Shortridge](https://www.aao.gov.au/science/research/staff/Keith%20Shortridge "Keith Shortridge, AAO")
from the Australian Astronomical Observatory (AAO) has created an implementation
for macOS that works pretty darn good. I have included it in this library for
completeness and convienience.

## PGReadWriteLock

**PGReadWriteLock** is an Objective-C class that provides a wrapper around the POSIX
read-write locks. As with PGSemaphore, this class provides implementations for the
[pthread_rwlock_timedrdlock](http://man7.org/linux/man-pages/man3/pthread_rwlock_timedrdlock.3p.html)
and [pthread_rwlock_timedwrlock](http://man7.org/linux/man-pages/man3/pthread_rwlock_timedwrlock.3p.html)
functions that don't exist in macOS.

### NOTE 1

One change **PGReadWriteLock** makes to the POSIX pthreads specification is that
**BOTH** the read and write locks are re-entrant rather than just the read locks.
The POSIX specification states that the behaviour when trying to obtain multiple
concurrent write locks by the same thread is undefined. The MAN page states that
a deadlock *could* occur in this case. The implementation of **PGReadWriteLock**
is to treat it the same as obtaining multiple read locks. The specification for
multiple read locks states:

> A thread may hold multiple concurrent read locks on rwlock (that is, successfully
> call the pthread_rwlock_rdlock() function n times). If so, the application shall
> ensure that the thread performs matching unlocks (that is, it calls the
> pthread_rwlock_unlock() function n times).

**PGReadWriteLock** handles this by maintaining it's own per-thread count of the
number of times the same thread obtains a write lock and insists that
<code>pthread_rwlock_unlock</code> is called that many times.

### NOTE 2

**PGReadWriteLock** *does not* support upgrading or downgrading locks. In other words,
if a thread currently holds one or more read locks then it cannot try to get a write
lock until it releases the read locks. The same applies to trying to get a read lock
while holding a write lock. Attempting to do so will cause an exception to be thrown.

