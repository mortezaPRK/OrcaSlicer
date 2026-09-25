orcaslicer_add_cmake_project(EXPAT
  # GIT_REPOSITORY https://github.com/nigels-com/glew.git
  # GIT_TAG 3a8eff7 # 2.1.0
  URL https://github.com/libexpat/libexpat/archive/refs/tags/R_2_8_5.tar.gz
  URL_HASH SHA256=fd022c541a189bd5bee042a22188351b31e39b9389c2525fa98c28bd05c9ef21
  SOURCE_SUBDIR expat
)

if (MSVC)
    add_debug_dep(dep_EXPAT)
endif ()
