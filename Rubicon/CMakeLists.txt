
file(GLOB_RECURSE libRubicon_SRC_C RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*.c")
file(GLOB_RECURSE libRubicon_SRC_M RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*.m")
file(GLOB_RECURSE libRubicon_HEADR RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*.h")
file(GLOB_RECURSE libRubicon_PRIVT RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "Private/*.h")

set(libRubicon_INC "")
foreach(afile ${libRubicon_HEADR})
	get_filename_component(dirname "${afile}" PATH)
	if(dirname STREQUAL "")
		list(APPEND libRubicon_INC ".")
	else()
		list(APPEND libRubicon_INC "${dirname}")
	endif()
endforeach(afile)
list(REMOVE_DUPLICATES libRubicon_INC)
include_directories(${libRubicon_INC})

list(REMOVE_ITEM libRubicon_HEADR ${libRubicon_PRIVT})

set_source_files_properties(${libRubicon_SRC_C} PROPERTIES LANGUAGE C COMPILE_FLAGS "-fblocks -std=gnu99")
set_source_files_properties(${libRubicon_SRC_M} PROPERTIES LANGUAGE C COMPILE_FLAGS "${objc_flags}")
set_source_files_properties(${libRubicon_HEADR} PROPERTIES LANGUAGE C COMPILE_FLAGS "" HEADER_FILE_ONLY YES)
set_source_files_properties(${libRubicon_PRIVT} PROPERTIES LANGUAGE C COMPILE_FLAGS "" HEADER_FILE_ONLY YES)

set(ALL_SRC_FILES ${libRubicon_SRC_C} ${libRubicon_SRC_M} ${libRubicon_HEADR} ${libRubicon_PRIVT})

check_function_exists(getentropy HAVE_GETENTROPY)
if(NOT HAVE_GETENTROPY)
    add_definitions(-D__PG_DEFINE_GETENTROPY__)
endif()

add_library(libRubicon_SHARED SHARED ${ALL_SRC_FILES})
target_link_libraries(libRubicon_SHARED)
set_target_properties(libRubicon_SHARED PROPERTIES LINKER_LANGUAGE C LINK_FLAGS "${objc_link_flags}" SOVERSION "${Rubicon_VERSION}" VERSION "${Rubicon_VERSION}" OUTPUT_NAME "${CMAKE_PROJECT_NAME}")

install(TARGETS libRubicon_SHARED ARCHIVE DESTINATION lib LIBRARY DESTINATION lib)
install(FILES ${libRubicon_HEADR} DESTINATION "include/${CMAKE_PROJECT_NAME}")
