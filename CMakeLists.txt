cmake_minimum_required(VERSION 3.15)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_VERBOSE_MAKEFILE ON) # 打印详细的编译命令
add_compile_options(-Wall)
add_compile_options(-g)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_BINARY_DIR})
list(APPEND CMAKE_PREFIX_PATH ${CMAKE_BINARY_DIR})
option(BUILD_TESTS "build tests " OFF)

# 简单起见, 当前仅使用 OpenSSL
add_definitions(-DHAVE_OPENSSL)
# FIXME: 当前支持 SSL 的代码有问题, 不能正常编译
#add_definitions(-DSSL_SUPPORT)
# 从原始编译参数提取出来的
add_compile_options(--std=gnu99)
add_definitions(-D_GNU_SOURCE)

# The version number.
set(UWSC_VERSION_MAJOR 3)
set(UWSC_VERSION_MINOR 3)
set(UWSC_VERSION_PATCH 5)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/src/config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h)

find_package(libev REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(spdlog REQUIRED)

project(uwsc)
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/src SRCS)
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/src/buffer SRCS)
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/src/log SRCS)
list(APPEND SRCS ${CMAKE_CURRENT_SOURCE_DIR}/src/ssl/openssl.c)

add_library(${PROJECT_NAME} STATIC ${SRCS})
target_compile_options(${PROJECT_NAME} PRIVATE -fPIC)

set(COMMON_INCLUDE_DIRS
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src/buffer
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src/log
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src/ssl
    PUBLIC ${CMAKE_CURRENT_BINARY_DIR}
    PRIVATE ${libev_INCLUDES}
    PRIVATE ${spdlog_INCLUDES} 
    PRIVATE ${OpenSSL_INCLUDES}
)
target_include_directories(${PROJECT_NAME} PRIVATE ${COMMON_INCLUDE_DIRS})

target_link_libraries(
    ${PROJECT_NAME}
    libev::libev 
    spdlog::spdlog
    OpenSSL::OpenSSL 
)

# usage: add_test(test_xxx, src0, src1, ...)
macro(add_test name)
    set(sources ${ARGN})
    set(prefixed_sources)
    # 遍历每个源文件，并添加前缀路径
    foreach(source IN LISTS sources)
        list(APPEND prefixed_sources "${CMAKE_CURRENT_SOURCE_DIR}/${source}")
    endforeach()
    message(STATUS "add_test(${name} ${prefixed_sources})")

    add_executable(${name} ${prefixed_sources})
    target_include_directories(${name} PRIVATE ${COMMON_INCLUDE_DIRS})
    target_link_libraries(
        ${name}
        ${PROJECT_NAME}
        GTest::gtest
        GTest::gtest_main
        spdlog::spdlog
    )
    #gtest_discover_tests(${name})
endmacro()

if(BUILD_TESTS)
    find_package(GTest REQUIRED)
    include(GoogleTest)
    add_test(example example/example.c)
endif()
