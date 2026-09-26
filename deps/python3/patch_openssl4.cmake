if(NOT DEFINED PYTHON_SOURCE_DIR)
    message(FATAL_ERROR "PYTHON_SOURCE_DIR is required")
endif()

set(_ssl_source "${PYTHON_SOURCE_DIR}/Modules/_ssl.c")
file(READ "${_ssl_source}" _source)
set(_original_source "${_source}")

set(_old "#if defined(SSL3_VERSION) && !defined(OPENSSL_NO_SSL3)")
set(_new "#if defined(SSL3_VERSION) && OPENSSL_VERSION_MAJOR < 4 && !defined(OPENSSL_NO_SSL3)")
string(FIND "${_source}" "${_old}" _position)
if(NOT _position EQUAL -1)
    string(REPLACE "${_old}" "${_new}" _source "${_source}")
elseif(NOT _source MATCHES "defined\\(SSL3_VERSION\\) && OPENSSL_VERSION_MAJOR < 4")
    message(FATAL_ERROR "Could not find CPython SSLv3 protocol guard in ${_ssl_source}")
endif()

foreach(_version TLS1 TLS1_1 TLS1_2)
    set(_old "defined(${_version}_VERSION) &&")
    set(_new "defined(${_version}_VERSION) && OPENSSL_VERSION_MAJOR < 4 &&")
    string(FIND "${_source}" "${_new}" _position)
    if(_position EQUAL -1)
        string(FIND "${_source}" "${_old}" _position)
        if(_position EQUAL -1)
            message(FATAL_ERROR "Could not find CPython ${_version} SSL method guard in ${_ssl_source}")
        endif()
        string(REPLACE "${_old}" "${_new}" _source "${_source}")
    endif()
endforeach()

if(NOT _source STREQUAL _original_source)
    file(WRITE "${_ssl_source}" "${_source}")
endif()

# Static OpenSSL also needs these Windows system libraries. The property sheet
# is unused by Unix builds; keep the patch identical across platforms.
set(_openssl_props "${PYTHON_SOURCE_DIR}/PCbuild/openssl.props")
file(READ "${_openssl_props}" _props)
set(_original_props "${_props}")
string(REPLACE "ws2_32.lib;libcrypto.lib;libssl.lib;"
               "ws2_32.lib;crypt32.lib;bcrypt.lib;libcrypto.lib;libssl.lib;"
               _props "${_props}")
if(NOT _props STREQUAL _original_props)
    file(WRITE "${_openssl_props}" "${_props}")
endif()

# Our static OpenSSL installation has no prebuilt-DLL directory containing its
# license. Include the license from the matching source archive in Python's bundle.
set(_regen_targets "${PYTHON_SOURCE_DIR}/PCbuild/regen.targets")
file(READ "${_regen_targets}" _targets)
set(_original_targets "${_targets}")
string(REPLACE "$(opensslOutDir)LICENSE" "$(OrcaOpenSSLLicenseDir)LICENSE"
               _targets "${_targets}")
if(NOT _targets STREQUAL _original_targets)
    file(WRITE "${_regen_targets}" "${_targets}")
endif()
