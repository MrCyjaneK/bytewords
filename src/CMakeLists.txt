# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(bytewords_library VERSION 0.0.1 LANGUAGES C)

add_library(bytewords SHARED
  "bytewords.c"
)

set_target_properties(bytewords PROPERTIES
  PUBLIC_HEADER bytewords.h
  OUTPUT_NAME "bytewords"
)

target_compile_definitions(bytewords PUBLIC DART_SHARED_LIB)
