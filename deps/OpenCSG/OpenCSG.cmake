
orcaslicer_add_cmake_project(OpenCSG
    # GIT_REPOSITORY https://github.com/floriankirsch/OpenCSG.git
    URL https://github.com/floriankirsch/OpenCSG/archive/refs/tags/opencsg-1-8-2-release.zip
    URL_HASH SHA256=f5095e5b14ff13b941f6abafea46f9cbc70ff0451deac56966dbc6e03c68801c
    PATCH_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt.in ./CMakeLists.txt
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_LIST_DIR}/patch_windows_loader.cmake
    DEPENDS dep_GLEW
)

if (TARGET ${ZLIB_PKG})
    add_dependencies(dep_OpenCSG ${ZLIB_PKG})
endif()

if (MSVC)
    add_debug_dep(dep_OpenCSG)
endif ()
