cmake_minimum_required(VERSION 3.6)

project ("NucleoF767 Board" C ASM)

## Enable static code analysis
#  the checks will be executed as it would be on the desired compile step
if(${ENABLE_STATIC_CHECKS})
   find_program(CLANG_TIDY clang-tidy
                NAMES clang-tidy-10 clang-tidy-9 clang-tidy-8 clang-tidy-7)
   message(STATUS "Looking for clang-tidy: ${CLANG_TIDY}")
   set(CMAKE_C_CLANG_TIDY   ${CLANG_TIDY} --extra-arg=--target=arm-none-eabi --extra-arg=-mthumb --extra-arg=--sysroot=${CMAKE_SYSROOT} -checks=-*,readability-*,clang-analyzer-*,-clang-analyzer-cplusplus*)
   set(CMAKE_CXX_CLANG_TIDY ${CLANG_TIDY} --extra-arg=--target=arm-none-eabi                     --extra-arg=--sysroot=${CMAKE_SYSROOT} -checks=-*,readability-*,clang-analyzer-*,-clang-analyzer-cplusplus*)
endif()

## Only compilable for target board
if(${CMAKE_CROSSCOMPILING})
   # BSP library for selected board
   file(GLOB BSP_SOURCES
      bsp/source/*.c
      bsp/source/*.s
      bsp/source/*.S
      bsp/source/protected/*.c
   )
   add_library(bsp STATIC ${BSP_SOURCES})
   target_include_directories(bsp
   PUBLIC
      bsp/include
   PRIVATE
      bsp/source/protected
   )
   # List of additional libs from board_config.cmake
   target_link_libraries(bsp PUBLIC essentials ${KISO_BOARD_LIBS})
endif(${CMAKE_CROSSCOMPILING})

# Include the tests for this module
if(${CMAKE_TESTING_ENABLED})
   #add_subdirectory(bsp/test)
endif()
