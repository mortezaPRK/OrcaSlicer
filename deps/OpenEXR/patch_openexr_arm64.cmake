# clang-cl provides ARM NEON intrinsics through arm_neon.h. Microsoft's
# arm64_neon.h wrappers reference MSVC-only neon_* intrinsics at link time.
set(_zip "src/lib/OpenEXRCore/internal_zip.c")
file(READ "${_zip}" _content)
set(_old "#    if defined(_MSC_VER)")
set(_new "#    if defined(_MSC_VER) && !defined(__clang__)")
string(FIND "${_content}" "${_new}" _already_patched)
if(_already_patched EQUAL -1)
    string(REPLACE "${_old}" "${_new}" _patched "${_content}")
    if(_patched STREQUAL _content)
        message(FATAL_ERROR "OpenEXR ARM64 NEON include guard was not found")
    endif()
    file(WRITE "${_zip}" "${_patched}")
endif()
