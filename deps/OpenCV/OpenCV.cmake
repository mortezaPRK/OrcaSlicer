# Intel IPP / IPP-ICV is x86/x64 only — there is no ARM64 build, so enabling it
# leaves ~200 unresolved ippicv* externals at link time on Windows ARM64.
if (MSVC AND NOT "${DEPS_ARCH}" STREQUAL "arm64")
    set(_use_IPP "-DWITH_IPP=ON")
    if (DEP_DEBUG)
        set(_options "FORWARD_CONFIG")
    endif ()
else ()
    set(_use_IPP "-DWITH_IPP=OFF")
    set(_options "")
endif ()

# carotene is OpenCV's ARM NEON HAL. It uses M_PI without _USE_MATH_DEFINES
# and does not compile with clang-cl.
set(_disable_carotene "")
if ("${DEPS_ARCH}" STREQUAL "arm64" AND CMAKE_CXX_COMPILER_ID STREQUAL Clang)
    set(_disable_carotene "-DWITH_CAROTENE=OFF")
    set(_opencv_patch_command PATCH_COMMAND ${CMAKE_COMMAND} -P
        ${CMAKE_CURRENT_LIST_DIR}/patch_clang_neon.cmake)
endif ()

# OpenCV's KleidiCV HAL adds ARM NEON translation units even when cross
# compiling the x86_64 macOS dependency bundle from an ARM runner.
set(_disable_kleidicv "")
if (APPLE AND "${DEPS_ARCH}" STREQUAL "x86_64")
    set(_disable_kleidicv "-DWITH_KLEIDICV=OFF")
endif ()

orcaslicer_add_cmake_project(OpenCV
    ${_options}
    URL https://github.com/opencv/opencv/archive/refs/tags/5.0.0.tar.gz
    URL_HASH SHA256=b0528f5a1d379d59d4701cb28c36e22214cc51cf64594e5b56f2d3e6c0233095
    ${_opencv_patch_command}
    CMAKE_ARGS
    -DBUILD_SHARED_LIBS=0
       -DBUILD_PERE_TESTS=OFF
       -DBUILD_TESTS=OFF
       -DBUILD_opencv_python_tests=OFF
       -DBUILD_EXAMPLES=OFF
       -DBUILD_JASPER=OFF
       -DBUILD_JAVA=OFF
       -DBUILD_JPEG=ON
       -DBUILD_APPS_LIST=version
       -DBUILD_opencv_apps=OFF
       -DBUILD_opencv_java=OFF
       -DBUILD_OPENEXR=OFF
       -DBUILD_PNG=ON
       -DBUILD_TBB=OFF
       -DBUILD_WEBP=OFF
       -DBUILD_ZLIB=OFF
       -DWITH_1394=OFF
       -DWITH_CUDA=OFF
       -DWITH_EIGEN=OFF
       ${_use_IPP}
       -DWITH_ITT=OFF
       -DWITH_FFMPEG=OFF
       -DWITH_GPHOTO2=OFF
       -DWITH_GSTREAMER=OFF
       -DOPENCV_GAPI_GSTREAMER=OFF
       -DWITH_GTK_2_X=OFF
       -DWITH_JASPER=OFF
       -DWITH_LAPACK=OFF
       -DWITH_MATLAB=OFF
       -DWITH_MFX=OFF
       -DWITH_DIRECTX=OFF
       -DWITH_DIRECTML=OFF
       -DWITH_OPENCL=OFF
       -DWITH_OPENCL_D3D11_NV=OFF
       -DWITH_OPENCLAMDBLAS=OFF
       -DWITH_OPENCLAMDFFT=OFF
       -DWITH_OPENEXR=OFF
       -DWITH_OPENJPEG=OFF
       -DWITH_QUIRC=OFF
       -DWITH_VTK=OFF
       -DWITH_JPEG=OFF
       -DWITH_WEBP=OFF
       -DWITH_TIFF=OFF
       -DBUILD_TIFF=OFF
       -DENABLE_PRECOMPILED_HEADERS=OFF
       -DINSTALL_TESTS=OFF
       -DINSTALL_C_EXAMPLES=OFF
       -DINSTALL_PYTHON_EXAMPLES=OFF
       -DOPENCV_GENERATE_SETUPVARS=OFF
       -DOPENCV_INSTALL_FFMPEG_DOWNLOAD_SCRIPT=OFF
       -DBUILD_opencv_python2=OFF
       -DBUILD_opencv_python3=OFF
       -DWITH_OPENVINO=OFF
       -DWITH_INF_ENGINE=OFF
       -DWITH_NGRAPH=OFF
       -DBUILD_WITH_STATIC_CRT=OFF#set /MDd /MD
       -DBUILD_LIST=core,imgcodecs,imgproc,world
       -DBUILD_opencv_highgui=OFF
       -DWITH_ADE=OFF
       -DBUILD_opencv_world=ON
       -DWITH_PROTOBUF=OFF
       -DWITH_WIN32UI=OFF
       -DHAVE_WIN32UI=FALSE
       ${_disable_carotene}
       ${_disable_kleidicv}
)

if(_opencv_patch_command)
    ExternalProject_Add_StepDependencies(dep_OpenCV patch
        "${CMAKE_CURRENT_LIST_DIR}/patch_clang_neon.cmake")
endif()
