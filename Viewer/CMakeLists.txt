cmake_minimum_required(VERSION 3.14)
project(Viewer)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -x objective-c")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
file( GLOB HEADER_FILES include/*.h )
file( GLOB SOURCE_FILES src/*.m src/*.mm )

set(XIB_FILES
    ./MainMenu.xib
    ./Window.xib
)

set(SHADERS shader.metal)

add_library(${PROJECT_NAME} STATIC
    ${HEADER_FILES}
    ${SOURCE_FILES}
    ${XIB_FILES}
    ${SHADERS})

target_link_libraries(${PROJECT_NAME}
    "-framework Cocoa"
    "-framework Metal"
    "-framework MetalKit"
    "-framework MetalPerformanceShaders"
    "-framework QuartzCore"
)


