# clang-cl cannot emit IGESAppli_GeneralModule.cxx on ARM64
# (llvm/llvm-project#62081). cl and clang-cl share an ABI.
set(_occt_compiler_args "")
if ("${DEPS_ARCH}" STREQUAL "arm64" AND CMAKE_CXX_COMPILER_ID STREQUAL Clang)
    set(_occt_compiler_args -DCMAKE_C_COMPILER:STRING=cl -DCMAKE_CXX_COMPILER:STRING=cl)
endif ()

set(_occt_install_args "")
if(WIN32)
    set(library_build_type "Shared")
    set(_occt_install_args -DINSTALL_DIR_BIN:STRING=bin/occt)
else()
    set(library_build_type "Static")
endif()

# SLIC3R_CAD (declared in deps/CMakeLists.txt) builds OCCT's ModelingAlgorithms module
# (fillet/offset/loft), whose only consumer is the parametric Design/CAD tab. With it OFF
# the deps prefix matches upstream exactly.
#
# With it ON the delta is THREE toolkits, not two: TKFillet (7.40 MiB archive, used via
# BRepFilletAPI), TKOffset (5.38 MiB, used via BRepOffsetAPI) and TKFeat (4.42 MiB), which
# nothing here references but which the module flag builds anyway -- it is all-or-nothing
# per module. The module's other nine toolkits are built either way, because DataExchange
# (the STEP path upstream already ships) depends on them.
#
# On macOS/Linux OCCT links statically, so an unreferenced toolkit costs build time and no
# shipped bytes. The Windows figure is a real DLL cost and has NOT been measured -- an
# earlier "3.77 MiB, Windows only" note here covered only two of the three toolkits and is
# not a number to quote. See docs/HLSD/design-tab.md.

if (IN_GIT_REPO)
    set(OCCT_DIRECTORY_FLAG --directory ${BINARY_DIR_REL}/dep_OCCT-prefix/src/dep_OCCT)
endif ()

orcaslicer_add_cmake_project(OCCT
    URL https://github.com/Open-Cascade-SAS/OCCT/archive/refs/tags/V8_0_1.zip
    URL_HASH SHA256=7c033d917ee8f040c0512d289dcc5f02c148889d5bac17c3e25639accb44f0da
    # OCCT 8.0 no longer needs the local patch written for older source layouts.
    #DEPENDS dep_Boost
    DEPENDS ${FREETYPE_PKG}
    CMAKE_ARGS
        -DCMAKE_CXX_STANDARD=17
        -DBUILD_LIBRARY_TYPE=${library_build_type}
        ${_occt_install_args}
        -DUSE_TK=OFF
        -DUSE_TBB=OFF
	#-DUSE_FREETYPE=OFF
        -DUSE_FFMPEG=OFF
        -DUSE_VTK=OFF
        -DBUILD_DOC_Overview=OFF
        -DBUILD_MODULE_ApplicationFramework=OFF
        #-DBUILD_MODULE_DataExchange=OFF
        -DBUILD_MODULE_Draw=OFF
        -DBUILD_MODULE_FoundationClasses=OFF
        -DBUILD_MODULE_ModelingAlgorithms=${SLIC3R_CAD}
        -DBUILD_MODULE_ModelingData=OFF
        -DBUILD_MODULE_Visualization=OFF
        ${_occt_compiler_args}
)

# add_dependencies(dep_OCCT ${FREETYPE_PKG})
