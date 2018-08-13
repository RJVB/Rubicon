/*
 *                       s e m _ t i m e d w a i t
 *
 *  Function:
 *     Implements a version of sem_timedwait().
 *
 *  Description:
 *     Not all systems implement sem_timedwait(), which is a version of
 *     sem_wait() with a timeout. Mac OS X is one example, at least up to
 *     and including version 10.6 (Leopard). If such a function is needed,
 *     this code provides a reasonable implementation, which I think is
 *     compatible with the standard version, although possibly less
 *     efficient. It works by creating a thread that interrupts a normal
 *     sem_wait() call after the specified timeout.
 *
 *  Call:
 *
 *     The Linux man pages say:
 *
 *     #include <semaphore.h>
 *
 *     int sem_timedwait(sem_t *sem, const struct timespec *abs_timeout);
 *
 *     sem_timedwait() is the same as sem_wait(), except that abs_timeout
 *     specifies a limit on the amount of time that the call should block if
 *     the decrement cannot be immediately performed. The abs_timeout argument
 *     points to a structure that specifies an absolute timeout in seconds and
 *     nanoseconds since the Epoch (00:00:00, 1 January 1970). This structure
 *     is defined as follows:
 *
 *     struct timespec {
 *        time_t tv_sec;      Seconds
 *        long   tv_nsec;     Nanoseconds [0 .. 999999999]
 *     };
 *
 *     If the timeout has already expired by the time of the call, and the
 *     semaphore could not be locked immediately, then sem_timedwait() fails
 *     with a timeout error (errno set to ETIMEDOUT).
 *     If the operation can be performed immediately, then sem_timedwait()
 *     never fails with a timeout error, regardless of the value of abs_timeout.
 *     Furthermore, the validity of abs_timeout is not checked in this case.
 *
 *  Limitations:
 *
 *     The mechanism used involves sending a SIGUSR2 signal to the thread
 *     calling sem_timedwait(). The handler for this signal is set to a null
 *     routine which does nothing, and with any flags for the signal
 *     (eg SA_RESTART) cleared. Note that this effective disabling of the
 *     SIGUSR2 signal is a side-effect of using this routine, and means it
 *     may not be a completely transparent plug-in replacement for a
 *     'normal' sig_timedwait() call. Since OS X does not declare the
 *     sem_timedwait() call in its standard include files, the relevant
 *     declaration (shown above in the man pages extract) will probably have
 *     to be added to any code that uses this.
 *
 *  Compiling:
 *     This compiles and runs cleanly on OS X (10.6) with gcc with the
 *     -Wall -ansi -pedantic flags. On Linux, using -ansi causes a sweep of
 *     compiler complaints about the timespec structure, but it compiles
 *     and works fine with just -Wall -pedantic. (Since Linux provides
 *     sem_timedwait() anyway, this really isn't needed on Linux.) However,
 *     since Linux provides sem_timedwait anyway, the sem_timedwait()
 *     code in this file is only compiled on OS X, and is a null on other
 *     systems.
 *
 *  Testing:
 *     This file contains a test program that exercises the sem_timedwait
 *     code. It is compiled if the pre-processor variable TEST is defined.
 *     For more details, see the comments for the test routine at the end
 *     of the file.
 *
 *  Author: Keith Shortridge, AAO.
 *
 *  History:
 *      8th Sep 2009. Original version. KS.
 *     24th Sep 2009. Added test that the calling thread still exists before
 *                    trying to set the timed-out flag. KS.
 *      2nd Oct 2009. No longer restores the original SIGUSR2 signal handler.
 *                    See comments in the body of the code for more details.
 *                    Prototypes for now discontinued internal routines removed.
 *     12th Aug 2010. Added the cleanup handler, so that this code no longer
 *                    leaks resources if the calling thread is cancelled. KS.
 *     21st Sep 2011. Added copyright notice below. Modified header comments
 *                    to describe the use of SIGUSR2 more accurately in the
 *                    light of the 2/10/09 change above. Now undefs DEBUG
 *                    before defining it, to avoid any possible clash. KS.
 *     14th Feb 2012. Tidied out a number of TABs that had got into the
 *                    code. KS.
 *      6th May 2013. Copyright notice modified to one based on the MIT licence,
 *                    which is more permissive than the previous notice. KS.
 *
 *  Copyright (c) Australian Astronomical Observatory (AAO), (2013).
 *  Permission is hereby granted, free of charge, to any person obtaining a
 *  copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 *  IN THE SOFTWARE.
 *//************************************************************************/
#ifdef __APPLE__
#ifndef sem_timedwait_h
#define sem_timedwait_h

#include <stdio.h>
#include <semaphore.h>

#if defined(__cplusplus)
extern "C" {
#endif

int sem_timedwait(sem_t *sem, const struct timespec *abs_timeout);

#if defined(__cplusplus)
}
#endif

#endif /* sem_timedwait_h */
#endif /* __APPLE__ */
