if(BUILD_SHARED_LIBS)
    set(_build_shared ON)
    set(_build_static OFF)
else()
    set(_build_shared OFF)
    set(_build_static ON)
endif()

if (IN_GIT_REPO)
    set(OPENVDB_DIRECTORY_FLAG --directory ${BINARY_DIR_REL}/dep_OpenVDB-prefix/src/dep_OpenVDB)
endif ()

orcaslicer_add_cmake_project(OpenVDB
    URL https://github.com/AcademySoftwareFoundation/openvdb/archive/refs/tags/v13.1.0.tar.gz
    URL_HASH SHA256=21659ef2330a06805519dd8d4369375f181a0dfee205b0180da69b4edd3329ae
    DEPENDS dep_TBB dep_Blosc dep_OpenEXR dep_Boost
    CMAKE_ARGS
        -DCMAKE_CXX_STANDARD=17
        # Match OrcaSlicer and the other Windows dependencies' DLL runtime.
        -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL
        -DOPENVDB_ABI_VERSION_NUMBER=13
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON 
        -DOPENVDB_BUILD_PYTHON_MODULE=OFF
        -DUSE_BLOSC=ON
        -DOPENVDB_CORE_SHARED=${_build_shared} 
        -DOPENVDB_CORE_STATIC=${_build_static}
        -DOPENVDB_ENABLE_RPATH:BOOL=OFF
        -DTBB_STATIC=${_build_static}
        -DOPENVDB_BUILD_VDB_PRINT=ON
        -DDISABLE_DEPENDENCY_VERSION_CHECKS=ON # Centos6 has old zlib
)

if (MSVC)
    if (${DEP_DEBUG})
        ExternalProject_Get_Property(dep_OpenVDB BINARY_DIR)
        ExternalProject_Add_Step(dep_OpenVDB build_debug
            DEPENDEES build
            DEPENDERS install
            COMMAND ${CMAKE_COMMAND} ../dep_OpenVDB -DOPENVDB_BUILD_VDB_PRINT=OFF -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebugDLL
            COMMAND msbuild /m /P:Configuration=Debug INSTALL.vcxproj
            WORKING_DIRECTORY "${BINARY_DIR}"
        )
    endif ()
endif ()
