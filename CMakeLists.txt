cmake_minimum_required(VERSION 3.14)

project(simGCS VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#
# CMake for the simGCS target, which is a GCS with a built in a UAS simulation.
# Tested on Linux and Android Emulator.
#
find_package(Qt5 REQUIRED COMPONENTS 
    Core 
    Quick 
    QuickControls2 
    Location
)
set(APP_HEADERS
    inc/TelemetrySimulator.hpp
    inc/QFlightMode.hpp
)
set(APP_SOURCES
    qml/qml.qrc
    src/main.cpp
    src/TelemetrySimulator.cpp
)
set(APP_LIBRARIES
    Qt5::Core 
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Location
)
if(ANDROID)
    add_library(simGCS SHARED
        ${APP_HEADERS}
        ${APP_SOURCES}
    )
else()
    add_executable(simGCS
        ${APP_HEADERS}
        ${APP_SOURCES}
    )
endif()
target_link_libraries(simGCS PRIVATE ${APP_LIBRARIES} )
target_include_directories(simGCS PRIVATE inc)

if(NOT ANDROID)
    #
    # Setup GoogleTest
    #
    include(FetchContent)
    FetchContent_Declare(
        googletest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG release-1.12.1
    )
    FetchContent_MakeAvailable(googletest)
    enable_testing()
    include_directories(${googletest_SOURCE_DIR}/include ${googletest_SOURCE_DIR})
    include(GoogleTest)

    #
    # add telemetry_simulator_tests
    #
    add_executable(telemetry_simulator_tests 
        test/TelemetrySimulatorTests.cpp 
        ${APP_HEADERS}
        src/TelemetrySimulator.cpp 
    )
    target_include_directories(telemetry_simulator_tests PRIVATE inc)
    target_link_libraries(telemetry_simulator_tests 
        gtest 
        ${APP_LIBRARIES}
    )
    gtest_discover_tests(telemetry_simulator_tests)
endif()
