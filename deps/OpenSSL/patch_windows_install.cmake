# Clang embeds debug information in its objects instead of producing MSVC's
# compiler PDB. Keep OpenSSL's static PDB installation optional for that build.
# https://github.com/openssl/openssl/issues/24939
file(READ "${OPENSSL_MAKEFILE}" _makefile)
set(_original [=[@if "$(SHLIBS)"=="" \]=])
set(_patched [=[@if "$(SHLIBS)"=="" if exist ossl_static.pdb \]=])
string(FIND "${_makefile}" "${_original}" _position)
if(NOT _position EQUAL -1)
    string(REPLACE "${_original}" "${_patched}" _makefile "${_makefile}")
    file(WRITE "${OPENSSL_MAKEFILE}" "${_makefile}")
else()
    string(FIND "${_makefile}" "${_patched}" _position)
    if(_position EQUAL -1)
        message(FATAL_ERROR "OpenSSL's Windows static PDB install rule was not found")
    endif()
endif()
