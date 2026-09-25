if(CMAKE_VERSION VERSION_LESS 3.22)
    set(_assimp_url "https://github.com/assimp/assimp/archive/refs/tags/v6.0.5.tar.gz")
    set(_assimp_hash "SHA256=edf3749559c2b7d1f758ffb66fc5bec62186221e623b7f2e8969f17ee46ecb6f")
else()
    set(_assimp_url "https://github.com/assimp/assimp/archive/refs/tags/v6.0.5.tar.gz")
    set(_assimp_hash "SHA256=edf3749559c2b7d1f758ffb66fc5bec62186221e623b7f2e8969f17ee46ecb6f")
endif()

# Assimp's bundled zlib (contrib/zlib) is too old to compile against the modern
# macOS SDK: its zutil.h takes the classic-Mac branch under TARGET_OS_MAC and
# does `#define fdopen(fd,mode) NULL`, which then clobbers the SDK's real
# `fdopen` prototype in <stdio.h> and breaks the build. On macOS use the system
# zlib (already found by find_package(ZLIB) in deps-unix-common) instead.
if(APPLE)
    set(_assimp_build_zlib "-DASSIMP_BUILD_ZLIB=OFF")
else()
    set(_assimp_build_zlib "-DASSIMP_BUILD_ZLIB=ON")
endif()

orcaslicer_add_cmake_project(Assimp
    URL ${_assimp_url}
    URL_HASH ${_assimp_hash}
    CMAKE_ARGS
        # Assimp's ccache support sets the global RULE_LAUNCH_COMPILE, which breaks
        # the Ninja RC rule. The superbuild forwards CMAKE_<LANG>_COMPILER_LAUNCHER.
        -DASSIMP_BUILD_USE_CCACHE=OFF
        -DASSIMP_BUILD_TESTS=OFF
        -DASSIMP_BUILD_SAMPLES=OFF
        -DASSIMP_BUILD_ASSIMP_TOOLS=OFF
        -DASSIMP_INSTALL_PDB=OFF
        -DASSIMP_NO_EXPORT=ON
        -DASSIMP_BUILD_ALL_IMPORTERS_BY_DEFAULT=OFF
        -DASSIMP_BUILD_GLTF_IMPORTER=ON
        -DASSIMP_BUILD_OBJ_IMPORTER=ON
        -DASSIMP_BUILD_FBX_IMPORTER=ON
        ${_assimp_build_zlib}
        -DASSIMP_WARNINGS_AS_ERRORS=OFF
        -DBUILD_WITH_STATIC_CRT=OFF
)

if (MSVC)
    add_debug_dep(dep_Assimp)
endif ()
