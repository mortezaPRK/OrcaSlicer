if(WIN32)
    set(library_build_shared "1")
else()
    set(library_build_shared "0")
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(_ft_disable_zlib "-D FT_DISABLE_ZLIB=FALSE")
else()
    set(_ft_disable_zlib "-D FT_DISABLE_ZLIB=TRUE")
endif()

orcaslicer_add_cmake_project(FREETYPE
    URL https://download.savannah.gnu.org/releases/freetype/freetype-2.14.3.tar.xz
    URL_HASH SHA256=36bc4f1cc413335368ee656c42afca65c5a3987e8768cc28cf11ba775e785a5f
    #DEPENDS ${ZLIB_PKG}
    #"${_patch_step}"
    CMAKE_ARGS
	-D BUILD_SHARED_LIBS=${library_build_shared}
	${_ft_disable_zlib}
        -D FT_DISABLE_BZIP2=TRUE
        -D FT_DISABLE_PNG=TRUE
        -D FT_DISABLE_HARFBUZZ=TRUE
        -D FT_DISABLE_BROTLI=TRUE
)

if(MSVC)
    add_debug_dep(dep_FREETYPE)
endif()
