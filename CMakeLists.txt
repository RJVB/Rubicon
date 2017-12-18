cmake_minimum_required(VERSION 3.5.2)

project (Rubicon VERSION "0.1.0.1")

find_library(Rubicon_libDispatch    NAMES "dispatch"     DOC "Location of libdispatch.")
find_library(Rubicon_libObjc2       NAMES "objc2" "objc" DOC "Location of libobjc.")
find_library(Rubicon_libGNUstepBase NAMES "gnustep-base" DOC "Location of libgnustep-base.")
find_library(Rubicon_libGNUstepGUI  NAMES "gnustep-gui"  DOC "Location of libgnustep-gui.")

if(NOT Rubicon_libObjc2)
	message(FATAL_ERROR "Unable to locate the required library objc or objc2.")
endif()

if(Rubicon_libDispatch)
	add_definitions("-DNF_DISPATCH=1")
else()
	add_definitions("-DNF_DISPATCH=0")
	message(WARNING "Unable to locate the required library for Grand Central Dispatch.  Will continue without support for Grand Central Dispatch.")
endif()

find_program(Rubicon_GNUstepConfig "gnustep-config")
if(Rubicon_GNUstepConfig)
	execute_process(COMMAND "${Rubicon_GNUstepConfig}" "--variable=CC"  OUTPUT_VARIABLE objc_c_compiler   OUTPUT_STRIP_TRAILING_WHITESPACE)
	execute_process(COMMAND "${Rubicon_GNUstepConfig}" "--variable=CXX" OUTPUT_VARIABLE objc_cxx_compiler OUTPUT_STRIP_TRAILING_WHITESPACE)

	set(CMAKE_C_COMPILER   "${objc_c_compiler}"   CACHE STRING "" FORCE)
	set(CMAKE_CXX_COMPILER "${objc_cxx_compiler}" CACHE STRING "" FORCE)
else()
	message(WARNING "Unable to locate gnustep-config. Proceeding with default compiler.")
endif()

if(Rubicon_libGNUstepBase)
	if(Rubicon_libGNUstepGUI)
		if(Rubicon_GNUstepConfig)
			execute_process(COMMAND "${Rubicon_GNUstepConfig}" "--objc-flags" OUTPUT_VARIABLE objc_def_flags      OUTPUT_STRIP_TRAILING_WHITESPACE)
			execute_process(COMMAND "${Rubicon_GNUstepConfig}" "--gui-libs"   OUTPUT_VARIABLE objc_def_link_flags OUTPUT_STRIP_TRAILING_WHITESPACE)

			set(objc_flags      "${objc_def_flags} -fobjc-runtime=gnustep-1.8.1 -fblocks -fobjc-arc -fobjc-arc-exceptions -DOS_OBJECT_HAVE_OBJC_SUPPORT=0")
			set(objc_link_flags "${objc_def_link_flags}")
		else()
			set(objc_defs       "-DOS_OBJECT_HAVE_OBJC_SUPPORT=0 -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_GUI_LIBRARY=1 -DGNU_RUNTIME=1 -DGNUSTEP_BASE_LIBRARY=1 -D_NATIVE_OBJC_EXCEPTIONS -D_NONFRAGILE_ABI")

			set(comm_feats      "-pthread -fexceptions -fobjc-nonfragile-abi -fgnu-runtime")
			set(objc_feats      "-fno-strict-aliasing -fobjc-exceptions -fobjc-runtime=gnustep-1.8.1 -fblocks -fobjc-arc -fobjc-arc-exceptions -fPIC -fconstant-string-class=NSConstantString")
			set(objc_warn       "-Wall -DGSWARN -DGSDIAGNOSE -Wno-import")
			set(objc_incld      "-I. -I/home/odroid/GNUstep/Library/Headers -I/usr/include")

			set(objc_flags      "-MMD -MP -std=gnu99 ${comm_feats} ${objc_feats} ${objc_defs} ${objc_warn} ${objc_incld}")
			set(objc_link_flags "-rdynamic ${comm_feats}")
		endif()
	else()
		message(FATAL_ERROR "Unable to locate the required library gnustep-gui.")
	endif()
else()
	message(FATAL_ERROR "Unable to locate the required library gnustep-base.")
endif()

if(NOT CMAKE_BUILD_TYPE)
    set (CMAKE_BUILD_TYPE "Release" CACHE STRING "" FORCE)
endif()

####################################################################################################################
# After we add the subdirectory for a library we can pull down it's include directories and add it to the parent's.
#
add_subdirectory("${CMAKE_PROJECT_NAME}")
get_directory_property(incdir DIRECTORY "${CMAKE_PROJECT_NAME}" INCLUDE_DIRECTORIES)
include_directories(${incdir})
#
####################################################################################################################
#
add_subdirectory("${CMAKE_PROJECT_NAME}Test")
get_directory_property(incdir2 DIRECTORY "${CMAKE_PROJECT_NAME}Test" INCLUDE_DIRECTORIES)
include_directories(${incdir2})
#
####################################################################################################################

if (UNIX)
	set(CPACK_STRIP_FILES               ON)
	set(CPACK_DEBIAN_PACKAGE_VERSION	"${Rubicon_VERSION}")
	set(CPACK_DEBIAN_PACKAGE_DEPENDS	"libc6 (>=2.7), libdispatch (>=0.1.3), libobjc (>=1.7.0)")
endif ()

set(CPACK_PACKAGE_CONTACT			 	"Galen Rhodes <galenrhodes@me.com>")
set(CPACK_PACKAGE_NAME					"lib${CMAKE_PROJECT_NAME}-${Rubicon_VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY	"Objective-C Library To Make Life Simple")
set(CPACK_RESOURCE_FILE_LICENSE			"${Rubicon_SOURCE_DIR}/LICENSE")
set(CPACK_PACKAGE_DESCRIPTION_FILE		"${Rubicon_SOURCE_DIR}/README.md")
set(CPACK_PACKAGE_VERSION_MAJOR			"${Rubicon_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR			"${Rubicon_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH			"${Rubicon_VERSION_PATCH}")
include (CPack)
