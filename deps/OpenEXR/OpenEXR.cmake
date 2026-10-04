if(FLATPAK)
    set(_openexr_offline_imath "-DFETCHCONTENT_SOURCE_DIR_IMATH=${DEP_DOWNLOAD_DIR}/Imath")
endif()

# Check if we're building for arm on x86_64 and just for OpenEXR, build fat
# binaries.  We need this because it compiles some code to generate other
# source and we need to be able to run the executables.  When we link the
# library, the x86_64 part will be ignored.
if (APPLE AND IS_CROSS_COMPILE)
    if (${CMAKE_SYSTEM_PROCESSOR} MATCHES "x86_64" AND ${CMAKE_OSX_ARCHITECTURES} MATCHES "arm")
        set(_openexr_arch arm64^^x86_64)
        set(_openxr_list_sep LIST_SEPARATOR ^^)
        set(_cmake_openexr_arch -DCMAKE_OSX_ARCHITECTURES:STRING=${_openexr_arch})
    else()
        set(_openexr_arch ${CMAKE_OSX_ARCHITECTURES})
        set(_cmake_openexr_arch -DCMAKE_OSX_ARCHITECTURES:STRING=${_openexr_arch})
    endif()
    ExternalProject_Add(dep_OpenEXR
        EXCLUDE_FROM_ALL    ON
        URL https://github.com/AcademySoftwareFoundation/openexr/archive/refs/tags/v3.5.0.tar.gz
        URL_HASH SHA256=0dc41a9dd84c868ad89c892382f75f6835a73decbefab9366d6f168bf9322954
        INSTALL_DIR         ${DESTDIR}
        DOWNLOAD_DIR        ${DEP_DOWNLOAD_DIR}/OpenEXR
        ${_openxr_list_sep}
        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX:STRING=${DESTDIR}
            -DBUILD_SHARED_LIBS:BOOL=OFF
            -DCMAKE_POSITION_INDEPENDENT_CODE=ON
            -DOPENEXR_FORCE_INTERNAL_ZSTD:BOOL=ON
            -DBUILD_TESTING=OFF 
            -DPYILMBASE_ENABLE:BOOL=OFF 
            -DOPENEXR_VIEWERS_ENABLE:BOOL=OFF
            -DOPENEXR_BUILD_UTILS:BOOL=OFF
            -DOPENEXR_IMATH_TAG:STRING=v3.2.3
            ${_cmake_openexr_arch}
    )
else()

set(_patch_cmd ${CMAKE_COMMAND} -P
    ${CMAKE_CURRENT_LIST_DIR}/patch_openexr_arm64.cmake)

orcaslicer_add_cmake_project(OpenEXR
    # GIT_REPOSITORY https://github.com/openexr/openexr.git
    URL https://github.com/AcademySoftwareFoundation/openexr/archive/refs/tags/v3.5.0.tar.gz
    URL_HASH SHA256=0dc41a9dd84c868ad89c892382f75f6835a73decbefab9366d6f168bf9322954
    PATCH_COMMAND ${_patch_cmd}
    DEPENDS ${ZLIB_PKG}
    CMAKE_ARGS
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
        -DBUILD_TESTING=OFF
        -DPYILMBASE_ENABLE:BOOL=OFF
        -DOPENEXR_VIEWERS_ENABLE:BOOL=OFF
        -DOPENEXR_BUILD_UTILS:BOOL=OFF
        -DOPENEXR_IMATH_TAG:STRING=v3.2.3
        -DOPENEXR_FORCE_INTERNAL_ZSTD:BOOL=ON
        ${_openexr_offline_imath}
        ${_openexr_arm64_args}
)
endif()

if (MSVC)
    add_debug_dep(dep_OpenEXR)
endif ()
