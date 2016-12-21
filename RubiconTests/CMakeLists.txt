
file(GLOB_RECURSE RubiconTest_SRC_C RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*.c")
file(GLOB_RECURSE RubiconTest_SRC_M RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*.m")
file(GLOB_RECURSE RubiconTest_HEADR RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*.h")
file(GLOB_RECURSE RubiconTest_PRIVT RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "/Private*.h")

set(RubiconTest_INC "")
foreach(afile ${RubiconTest_HEADR})
	get_filename_component(dirname "${afile}" PATH)
	if(dirname STREQUAL "")
		list(APPEND RubiconTest_INC ".")
	else()
		list(APPEND RubiconTest_INC "${dirname}")
	endif()
endforeach(afile)
list(REMOVE_DUPLICATES RubiconTest_INC)
include_directories(${RubiconTest_INC})

list(REMOVE_ITEM RubiconTest_HEADR ${RubiconTest_PRIVT})

set_source_files_properties(${RubiconTest_SRC_C} PROPERTIES LANGUAGE C COMPILE_FLAGS "-fblocks -std=gnu99")
set_source_files_properties(${RubiconTest_SRC_M} PROPERTIES LANGUAGE C COMPILE_FLAGS "${objc_flags}")
set_source_files_properties(${RubiconTest_HEADR} PROPERTIES LANGUAGE C COMPILE_FLAGS HEADER_FILE_ONLY YES)
set_source_files_properties(${RubiconTest_PRIVT} PROPERTIES LANGUAGE C COMPILE_FLAGS HEADER_FILE_ONLY YES)

set(RubiconTest_ALL_SRC ${RubiconTest_SRC_C} ${RubiconTest_SRC_M} ${RubiconTest_HEADR} ${RubiconTest_PRIVT})

add_executable(RubiconTestExe ${RubiconTest_ALL_SRC})
set_target_properties(RubiconTestExe PROPERTIES LINKER_LANGUAGE C LINK_FLAGS "${objc_link_flags}" OUTPUT_NAME "${CMAKE_PROJECT_NAME}Test")
target_link_libraries(RubiconTestExe libNiagraFalls_SHARED)

