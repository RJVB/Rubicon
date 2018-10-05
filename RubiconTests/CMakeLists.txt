
file(GLOB_RECURSE RubiconTests_SRC_C RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*.c")
file(GLOB_RECURSE RubiconTests_SRC_M RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*.m")
file(GLOB_RECURSE RubiconTests_HEADR RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*.h")

set(RubiconTests_INC "")
foreach(afile ${RubiconTests_HEADR})
	get_filename_component(dirname "${afile}" PATH)
	if(dirname STREQUAL "")
		list(APPEND RubiconTests_INC ".")
	else()
		list(APPEND RubiconTests_INC "${dirname}")
	endif()
endforeach(afile)
list(REMOVE_DUPLICATES RubiconTests_INC)
include_directories(${RubiconTests_INC})

set_source_files_properties(${RubiconTests_SRC_C} PROPERTIES LANGUAGE C COMPILE_FLAGS "-fblocks -std=gnu99")
set_source_files_properties(${RubiconTests_SRC_M} PROPERTIES LANGUAGE C COMPILE_FLAGS "${objc_flags}")
set_source_files_properties(${RubiconTests_HEADR} PROPERTIES LANGUAGE C COMPILE_FLAGS "" HEADER_FILE_ONLY YES)

set(ALL_SRC_FILES ${RubiconTests_SRC_C} ${RubiconTests_SRC_M} ${RubiconTests_HEADR})

add_executable(Rubicon_TEST ${ALL_SRC_FILES})
set_target_properties(Rubicon_TEST PROPERTIES LINKER_LANGUAGE C LINK_FLAGS "${objc_link_flags}")
