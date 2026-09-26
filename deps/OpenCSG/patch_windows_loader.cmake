# OpenCSG wraps its GLAD loader in a namespace. Windows ARM64 intrinsics must
# be declared in the global namespace before the loader includes windows.h.
set(_loader "src/glad/src/gl.cpp")
file(READ "${_loader}" _content)
set(_before "#include <string.h>\n\nnamespace OpenCSG {")
set(_after "#include <string.h>\n\n#if defined(_WIN32)\n#include <windows.h>\n#endif\n\nnamespace OpenCSG {")
string(FIND "${_content}" "${_after}" _already_patched)
if(_already_patched EQUAL -1)
    string(REPLACE "${_before}" "${_after}" _patched "${_content}")
    if(_patched STREQUAL _content)
        message(FATAL_ERROR "OpenCSG GLAD loader preamble was not found")
    endif()
    file(WRITE "${_loader}" "${_patched}")
endif()
