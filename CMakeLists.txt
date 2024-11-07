cmake_minimum_required(VERSION 3.25)
project(color-control)

include(cmake/CPM.cmake)

find_package(Threads REQUIRED)

CPMAddPackage("gh:chriskohlhoff/asio#asio-1-32-0@1.32.2")
CPMAddPackage("gh:getml/reflect-cpp@0.14.1")

if (asio_ADDED)
    add_library(asio INTERFACE)
    target_include_directories(asio SYSTEM INTERFACE ${asio_SOURCE_DIR}/asio/include)
    target_compile_definitions(asio INTERFACE ASIO_STANDALONE ASIO_NO_DEPRECATED)
    target_link_libraries(asio INTERFACE Threads::Threads)
endif ()

add_executable(color-control src/main.cpp)
set_property(TARGET color-control PROPERTY CXX_STANDARD 23)
target_link_libraries(color-control asio reflectcpp)