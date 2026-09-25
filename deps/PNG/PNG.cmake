if (APPLE)
    # Only disable NEON extension for Apple ARM builds, leave it enabled for Raspberry PI.
    set(_disable_neon_extension "-DPNG_ARM_NEON=off")
elseif ("${DEPS_ARCH}" STREQUAL "arm64")
    # libpng's CMake ignores PNG_ARM_NEON on Windows ARM64 and skips the NEON
    # sources, but pngpriv.h enables NEON anyway.
    set(_disable_neon_extension "-DCMAKE_C_FLAGS=/DWIN32 /D_WINDOWS /DPNG_ARM_NEON_OPT=0")
else ()
    set(_disable_neon_extension "")
endif ()

if(APPLE AND IS_CROSS_COMPILE)
# TODO: check if it doesn't create problem when compiling from arm to x86_64
    orcaslicer_add_cmake_project(PNG 
        GIT_REPOSITORY https://github.com/pnggroup/libpng.git
        GIT_TAG v1.6.56
        DEPENDS ${ZLIB_PKG}
        CMAKE_ARGS
            -DPNG_SHARED=OFF
            -DPNG_STATIC=ON
            -DPNG_PREFIX=prusaslicer_
            -DPNG_TESTS=OFF
            -DDISABLE_DEPENDENCY_TRACKING=OFF
            ${_disable_neon_extension}
    )
else ()
    orcaslicer_add_cmake_project(PNG 
        URL https://github.com/pnggroup/libpng/archive/refs/tags/v1.6.56.zip
        URL_HASH SHA256=dd5fc50c344b276f506d951432464dd0909764d45f9e0bd05871a761e9072ff4
        DEPENDS ${ZLIB_PKG}
        CMAKE_ARGS
            -DPNG_SHARED=OFF
            -DPNG_STATIC=ON
            -DPNG_PREFIX=prusaslicer_
            -DPNG_TESTS=OFF
            -DDISABLE_DEPENDENCY_TRACKING=OFF
            ${_disable_neon_extension}
)
endif()

if (MSVC)
    add_debug_dep(dep_PNG)
endif ()
