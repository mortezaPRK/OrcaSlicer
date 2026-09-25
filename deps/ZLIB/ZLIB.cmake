orcaslicer_add_cmake_project(ZLIB
  URL https://github.com/madler/zlib/archive/refs/tags/v1.3.2.zip
  URL_HASH SHA256=31fd9fee98812abcf147d0e103bc4d2f983c35a8d7a807a328a299f3a74e0050
  CMAKE_ARGS
    -DZLIB_BUILD_SHARED=OFF
    -DZLIB_BUILD_STATIC=ON
    -DSKIP_INSTALL_FILES=ON         # Prevent installation of man pages et al.
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
)
