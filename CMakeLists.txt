cmake_minimum_required(VERSION 3.6)

## Command line parameter for build variant
option(ENABLE_TESTING "Configure a build tree for testing instead of normal application mode" OFF)
option(ENABLE_FORMAT_CHECKS "Run format checks during configuration stage and generate target to fix formatting" OFF)
option(SKIP_FORMAT_REPORTS "Skip generation of format XML reports in build directory" ON)
option(ENABLE_STATIC_CHECKS "Configure a build tree for static code analysis" OFF)
option(ENABLE_COVERAGE "Build unit tests with coverage information to use with GCOV and LCOV" ON)

## Include config file if it exists
include(kiso_defaults.cmake OPTIONAL)

## If no external toolchain is specified and we are not building just the unit tests, use the default arm toolchain.
## Should be included as early as possible, before any project specification.
if (NOT DEFINED CMAKE_TOOLCHAIN_FILE AND NOT ${ENABLE_TESTING})
   # Use full path as it's before project() command
   include(cmake/ArmToolchain.cmake)
endif()

message("------------- KISO CONFIG -------------")
message("Building Kiso tests:   ${ENABLE_TESTING}")
message("  ... with coverage:   ${ENABLE_COVERAGE}")
message("Kiso Board Path:       ${KISO_BOARD_PATH}")
message("Kiso OS:               ${KISO_OS_LIB}")
message("Kiso Application Path: ${KISO_APPLICATION_PATH}")
message("Project Config Path:   ${PROJECT_CONFIG_PATH}")
message("------------- KISO CONFIG -------------")

project (Kiso C)

## Set basic project compile options
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_EXTENSIONS false)
set(CMAKE_POSITION_INDEPENDENT_CODE OFF)
add_compile_options(-Werror -Wall -Wextra -Wdouble-promotion
                    -Wformat=2 -Winit-self -Wunused -Wunused-const-variable -Wnull-dereference
                    -Wuninitialized -fstrict-overflow -Wstrict-overflow=4 -Wshadow -Wcast-qual)

## Run format checks during configure stage
if(${ENABLE_FORMAT_CHECKS})
   include(CodeFormatting)
   list(APPEND FOLDERS
      core thirdparty examples boards config)
   list(APPEND FILETYPES
      *.c *.cc *.cpp *.cxx *.c++
      *.h *.hh *.hpp *.hxx *.h++)
   ADD_TO_FORMATTING_TARGET("${FOLDERS}" "${FILETYPES}" "${SKIP_FORMAT_REPORTS}")
endif()

## Needs to be in project scope before board is loaded
if(${ENABLE_TESTING})
   enable_language(CXX)
   set(CMAKE_CXX_STANDARD 11)
   set(CMAKE_BUILD_TYPE Debug)

   # In the gtest lib there are problems with these warnings - disable them
   add_compile_options(-Wno-unused-const-variable -Wno-missing-field-initializers -Wno-pedantic -Wno-error=deprecated-declarations)

   enable_testing()
   if(${ENABLE_COVERAGE})
      include(CodeCoverage)

      APPEND_COVERAGE_COMPILER_FLAGS() # From CodeCoverage module
      # Do not include coverage information for system headers and thirdparty libs
      set(COVERAGE_LCOV_EXCLUDES "'/usr/include/*'" "'/usr/local/include/*'" "'${CMAKE_SOURCE_DIR}/thirdparty/*'" "*_unittest.cc" "*_th.hh")

      add_custom_target(coverage)
   endif(${ENABLE_COVERAGE})
endif(${ENABLE_TESTING})

## Check for valid board and include the configuration
if(NOT DEFINED KISO_BOARD_PATH)
   message(SEND_ERROR "KISO_BOARD_PATH is a required parameter! Use cmake <...> -DKISO_BOARD_PATH=... to specify.")
else()
   get_filename_component(ABS_BOARD_PATH ${KISO_BOARD_PATH} REALPATH)
   if(NOT EXISTS ${ABS_BOARD_PATH}/board_config.cmake) # Use full path - undefined behavior with relative path
      message(SEND_ERROR "board_config.cmake missing for board ${KISO_BOARD_PATH}")
   else()
      include(${ABS_BOARD_PATH}/board_config.cmake)
      add_subdirectory(${ABS_BOARD_PATH} ${CMAKE_CURRENT_BINARY_DIR}/boards/${KISO_BOARD_NAME})
   endif()
endif()

if(${ENABLE_STATIC_CHECKS})
   find_program(CLANG_TIDY clang-tidy
      NAMES clang-tidy-10 clang-tidy-9 clang-tidy-8 clang-tidy-7)
      message(STATUS "Looking for clang-tidy: ${CLANG_TIDY}")
endif()

## Add application code
add_subdirectory(${KISO_APPLICATION_PATH} ${CMAKE_CURRENT_BINARY_DIR}/applications/${KISO_APPLICATION_NAME})

include(KisoLibsConfig)

## Add board and core libs
#add_subdirectory(boards)
add_subdirectory(core/essentials)
add_subdirectory(core/utils)
add_subdirectory(core/connectivity/cellular)

## Add thirdparty libs
add_subdirectory(thirdparty)

## Add the documentation (not built by default target)
add_subdirectory(docs)
