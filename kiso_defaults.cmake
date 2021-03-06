
## Default configuration for the project

## This file sets the defaults in case some variable
## is not provided as a command line argument
## to CMake invocation

## Optionally use custom compiler for unit tests build
## Instead of using the default for the Host
if(${ENABLE_TESTING})
   # set(CMAKE_C_COMPILER /usr/local/bin/gcc)
   # set(CMAKE_CXX_COMPILER /usr/local/bin/g++)
endif()

## Toolchain prefix to search for in application builds
## if not provided by command line argument
## Default is 'arm-none-eabi-'
if(NOT ARM_TOOLCHAIN_PREFIX)
   # set(ARM_TOOLCHAIN_PREFIX arm-none-eabi-)
endif()

## Provide path where ${ARM_TOOLCHAIN_PREFIX}gcc executable is located
## instead of using the one in PATH
# set(ARM_TOOLCHAIN_DIR /usr/local/arm-gcc/bin)

## Board name to compile for
if(NOT KISO_BOARDS_ROOT_PATH)
   set(KISO_BOARDS_ROOT_PATH boards)
endif()

if(NOT KISO_BOARD_NAME)
   set(KISO_BOARD_NAME CommonGateway)
endif()

if(NOT KISO_BOARD_PATH)
   set(KISO_BOARD_PATH ${KISO_BOARDS_ROOT_PATH}/${KISO_BOARD_NAME})
endif()

## OS to use (only option is freertos for now)
if(NOT KISO_OS_LIB)
   set(KISO_OS_LIB freertos)
endif()

## Use this application directory to build the application
if(NOT KISO_APPLICATIONS_ROOT_PATH)
   set(KISO_APPLICATIONS_ROOT_PATH examples)
endif()

if(NOT KISO_APPLICATION_NAME)
   set(KISO_APPLICATION_NAME c-leds)
endif()

if(NOT KISO_APPLICATION_PATH)
   set(KISO_APPLICATION_PATH ${KISO_APPLICATIONS_ROOT_PATH}/${KISO_BOARD_NAME}/${KISO_APPLICATION_NAME})
endif()

## Directory with configuration headers for packages
if(NOT PROJECT_CONFIG_PATH)
   set(PROJECT_CONFIG_PATH ${CMAKE_SOURCE_DIR}/config)
endif()
