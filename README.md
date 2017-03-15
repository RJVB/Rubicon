#Rubicon

Rubicon is an Objective-C library designed to speed cross-platform development by filling
in the missing pieces between the official Apple version of it's Foundation classes and
the [GNUstep](http://www.gnustep.org) version of the Foundation classes.

###Linux vs Mac OS X

Rubicon also attempts to smooth out some of the more glaring differences between the Linux
operating system and the Mac OS X operating system such as the former's glaring omission
of the [int clock_gettime(clockid_t clk_id, struct timespec *tp);](https://linux.die.net/man/3/clock_gettime)
function in versions prior to 10.12 (_macOS Sierra_).

###Additions

Rubicon also provides some of my own additions, (defines, functions, classes, protocols,
and categories) to make development easier in general even if it's not cross-platform.

For example, Rubicon includes an implementation of a full red-black binary tree that is
independent of the NSDictionary and NSSet classes.  This allows you to use a super fast
binary tree in your own classes without the overhead of the NSDictionary and NSSet
collection classes.


