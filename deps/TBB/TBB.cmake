if (MSVC)
    set(_patch_command ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/MSVC.cmake ./cmake/compilers/MSVC.cmake)
elseif (FLATPAK AND "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    set(_patch_command ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/GNU.cmake ./cmake/compilers/GNU.cmake)
else()
    set(_patch_command "")
endif()

orcaslicer_add_cmake_project(
    TBB
    URL "https://github.com/oneapi-src/oneTBB/archive/refs/tags/v2023.1.0.zip"
    URL_HASH SHA256=0712621d19d2fbc1dc0d4e964bf8d9592c78d79f62991d2173bad741a7461c4a
    PATCH_COMMAND ${_patch_command}
    CMAKE_ARGS          
        -DTBB_BUILD_SHARED=OFF
        -DTBB_BUILD_TESTS=OFF
        -DTBB_TEST=OFF
        -DTBB_DISABLE_HWLOC_AUTOMATIC_SEARCH=ON
        -DTBB_ENABLE_IPO=OFF
        -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
        -DCMAKE_DEBUG_POSTFIX=_debug
)

if (MSVC)
    add_debug_dep(dep_TBB)
endif ()

