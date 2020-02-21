cmake_minimum_required(VERSION 3.14)
project(Viewer)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -x objective-c")

file( GLOB HEADER_FILES *.h )
file( GLOB SOURCE_FILES *.m *.mm )

set(XIB_FILE
    ./MainMenu.xib
    ./Window.xib
)

set(SHADERS shader.metal)

add_executable(
    ${PROJECT_NAME}
    ${HEADER_FILES}
    ${SOURCE_FILES}
    ${XIB_FILE}
    ${SHADERS}
)

target_link_libraries(${PROJECT_NAME}
    "-framework Cocoa"
    "-framework Metal"
    "-framework MetalKit"
    "-framework MetalPerformanceShaders"
)


