
include(ProcessorCount)
ProcessorCount(NPROC)

if(DEFINED OPENSSL_ARCH)
    set(_cross_arch ${OPENSSL_ARCH})
else()
    if(WIN32)
        if("${DEPS_ARCH}" STREQUAL "arm64")
            set(_cross_arch "VC-WIN64-ARM")
        else()
            set(_cross_arch "VC-WIN64A")
        endif()
    elseif(APPLE)
        set(_cross_arch "darwin64-${CMAKE_OSX_ARCHITECTURES}-cc")
	endif()
endif()

if(WIN32)
    # Resolve native MSVC tools from the developer environment. /FS serializes
    # writes to OpenSSL's shared compiler PDB.
    set(_openssl_msvc_env CC=cl CXX=cl RC=rc CL=/FS)
    if(DEPS_ARCH STREQUAL "arm64" AND CMAKE_C_COMPILER_ID STREQUAL "Clang")
        # MSVC 19.51 miscompiles the TLS extension parser's ARM64 prologue.
        # OpenSSL 4 quotes the selected compiler's path in its nmake file.
        set(_openssl_msvc_env
            "CC=${CMAKE_C_COMPILER}"
            "CXX=${CMAKE_CXX_COMPILER}"
            RC=rc)
        if(NOT DEFINED OPENSSL_ARCH)
            set(_cross_arch "VC-CLANG-WIN64-CLANGASM-ARM")
        endif()
    endif()
    set(_conf_cmd ${CMAKE_COMMAND} -E env ${_openssl_msvc_env} perl Configure )
    set(_cross_comp_prefix_line "")
    if("${DEPS_ARCH}" STREQUAL "arm64")
        # OpenSSL's VC configs pass /Gs0, which puts a __chkstk probe in every
        # function. MSVC 14.51 and 14.52 (VS 2026) for ARM64 emit that call
        # before the prologue saves LR, so the function returns into itself;
        # in tls_parse_all_extensions that breaks every TLS handshake. 14.44
        # (VS 2022) is unaffected. Restore cl's default threshold: Configure
        # appends /Gs4096 after /Gs0, and the later option wins.
        set(_openssl_extra_cflags /Gs4096)
    endif()
    # Build the libraries only. The openssl.exe app has no runtime use in OrcaSlicer
    # and OpenSSL 4's app target does not compile with the clang-cl ARM config.
    set(_make_cmd ${CMAKE_COMMAND} -E env ${_openssl_msvc_env} nmake build_libs)
    set(_install_cmd
        ${CMAKE_COMMAND} -DOPENSSL_MAKEFILE=<SOURCE_DIR>/makefile
            -P ${CMAKE_CURRENT_LIST_DIR}/patch_windows_install.cmake
        COMMAND ${CMAKE_COMMAND} -E env ${_openssl_msvc_env} nmake install_dev)
else()
    if(APPLE)
        set(_conf_cmd export MACOSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET} && ./Configure -mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET})
    else()
        set(_conf_cmd env "CC=${CMAKE_C_COMPILER}" "LDFLAGS=${CMAKE_EXE_LINKER_FLAGS}" "./config")
    endif()
    set(_cross_comp_prefix_line "")
    set(_make_cmd make -j${NPROC})
    set(_install_cmd make -j${NPROC} install_sw)
    if (CMAKE_CROSSCOMPILING)
        set(_cross_comp_prefix_line "--cross-compile-prefix=${TOOLCHAIN_PREFIX}-")

        if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "aarch64" OR ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "arm64")
            set(_cross_arch "linux-aarch64")
        elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "armhf") # For raspbian
            # TODO: verify
            set(_cross_arch "linux-armv4")
        endif ()
    endif ()
endif()

ExternalProject_Add(dep_OpenSSL
    #EXCLUDE_FROM_ALL ON
    URL "https://github.com/openssl/openssl/archive/refs/tags/openssl-4.0.2.tar.gz"
    URL_HASH SHA256=0c79e20fe326f50eb2ef58ee45306db2258d55bd16f6dbf6061658a1cad48c35
    # URL "https://github.com/openssl/openssl/archive/refs/tags/openssl-3.1.2.tar.gz"
    # URL_HASH SHA256=8c776993154652d0bb393f506d850b811517c8bd8d24b1008aef57fbe55d3f31
    DOWNLOAD_DIR ${DEP_DOWNLOAD_DIR}/OpenSSL
	CONFIGURE_COMMAND ${_conf_cmd} ${_cross_arch}
        "--openssldir=${DESTDIR}"
        "--prefix=${DESTDIR}"
        # OpenSSL's linux-x86_64 target sets multilib=64, so it installs to
        # <prefix>/lib64 while every other dep uses <prefix>/lib. CPython's
        # --with-openssl only ever emits -L<dir>/lib, so it misses the bundled
        # static libs and silently links the system OpenSSL instead -- which,
        # against 1.1.1w headers, leaves _ssl.so with an undefined
        # SSL_get_peer_certificate (removed in OpenSSL 3.x). Pin libdir so the
        # prefix stays single-layout.
        "--libdir=lib"
        ${_cross_comp_prefix_line}
        ${_openssl_extra_cflags}
        no-shared
        no-asm
        no-ssl3-method
        no-dynamic-engine
    BUILD_IN_SOURCE ON
    BUILD_COMMAND ${_make_cmd}
    INSTALL_COMMAND ${_install_cmd}
)

if(WIN32)
    ExternalProject_Add_StepDependencies(dep_OpenSSL install
        "${CMAKE_CURRENT_LIST_DIR}/patch_windows_install.cmake")
endif()

if (CMAKE_GENERATOR MATCHES "Visual Studio")
    # nmake needs the native MSVC/SDK tools even when the C compiler is Clang.
    set_target_properties(dep_OpenSSL PROPERTIES VS_PLATFORM_TOOLSET "$(DefaultPlatformToolset)")
endif ()
