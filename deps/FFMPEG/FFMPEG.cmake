set(_conf_cmd ./configure)

set(_ffmpeg_depends)
set(_ffmpeg_configure_command ${_conf_cmd})
if (TARGET dep_OpenSSL)
    set(_ffmpeg_depends DEPENDS dep_OpenSSL)
    set(_ffmpeg_configure_command
        ${CMAKE_COMMAND} -E env
        "PKG_CONFIG_PATH=${DESTDIR}/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}"
        ${_conf_cmd}
    )
endif()

if (MSVC)
    set(_source_dir "${CMAKE_BINARY_DIR}/dep_FFMPEG-prefix/src/dep_FFMPEG")

    # The September 25 and 26 ARM64 builds crash in avcodec's TLS initializer,
    # including when launching their own ffmpeg.exe. Keep the tested 9.0.2 build.
    set(PREBUILD_URL_arm64 "https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2026-09-21-13-55/ffmpeg-n9.0.2-3-ga5923073bf-winarm64-lgpl-shared-9.0.zip")
    set(PREBUILD_HASH_arm64 "08a62bdd6dadd556cf29e5e0602a18f355e9fd8bbb5a96268de489cc48466718")
    set(PREBUILD_URL_x64 "https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2026-09-26-13-03/ffmpeg-n9.0.2-10-g51c4a23d74-win64-lgpl-shared-9.0.zip")
    set(PREBUILD_HASH_x64 "8f3a5190804eed8c0f4927dbac688bcc35a1d2b9c36d7bf9a4386ec7bd1627ed")

    ExternalProject_Add(dep_FFMPEG
        ${_ffmpeg_depends}
        URL ${PREBUILD_URL_${DEPS_ARCH}}
        URL_HASH SHA256=${PREBUILD_HASH_${DEPS_ARCH}}
        DOWNLOAD_DIR ${DEP_DOWNLOAD_DIR}/FFMPEG
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND
            COMMAND ${CMAKE_COMMAND} -E copy_directory  "${_source_dir}/bin" "${DESTDIR}/bin"
            COMMAND ${CMAKE_COMMAND} -E copy_directory  "${_source_dir}/lib" "${DESTDIR}/lib"
            COMMAND ${CMAKE_COMMAND} -E copy_directory  "${_source_dir}/include" "${DESTDIR}/include"
    )

else ()
    set(_openssl_cmd --enable-openssl)

    if (APPLE)
        set(_minos_cmd
            "--extra-cflags=-mmacosx-version-min=${DEP_OSX_TARGET}"
            "--extra-ldflags=-mmacosx-version-min=${DEP_OSX_TARGET}"
            )
        # Static FFmpeg: nothing to bundle into the .app, no rpath handling.
        # Disable the VideoToolbox/AudioToolbox HW-accel paths: the player decodes
        # in software (swscale), and the auto-detected HW objects would drag in
        # system frameworks that the static libs would then depend on.
        set(_link_cmd --enable-static --disable-shared --disable-videotoolbox --disable-audiotoolbox)
        if (IS_CROSS_COMPILE)
            set(_cross_cmd --enable-cross-compile)
            set(_pic_cmd --enable-pic)
            if (${CMAKE_SYSTEM_PROCESSOR} MATCHES "x86_64")
                set(_arch_cmd --arch=arm64)
                set(_cc_cmd "--cc=clang -arch arm64")
            else()
                set(_arch_cmd --arch=x86_64)
                set(_cc_cmd "--cc=clang -arch x86_64")
            endif()
        endif()
    else ()
        set(_link_cmd --enable-shared)
    endif ()

    set(_build_j -j)
    if(DEFINED ENV{CMAKE_BUILD_PARALLEL_LEVEL})
        set(_build_j "-j$ENV{CMAKE_BUILD_PARALLEL_LEVEL}")
    endif()

    ExternalProject_Add(dep_FFMPEG
        ${_ffmpeg_depends}
        URL https://ffmpeg.org/releases/ffmpeg-9.0.2.tar.xz
        URL_HASH SHA256=8c3850283eb25fa026482078a04051e0be17347b09ef81a0849bec15a96e002e
        DOWNLOAD_DIR ${DEP_DOWNLOAD_DIR}/FFMPEG
        CONFIGURE_COMMAND ${_ffmpeg_configure_command}
            ${_cross_cmd}
            ${_pic_cmd}
            ${_arch_cmd}
            ${_cc_cmd}
            "--prefix=${DESTDIR}"
            ${_link_cmd}
            ${_minos_cmd}
            ${_openssl_cmd}
            --disable-doc
            --enable-small
            --disable-outdevs
            --disable-filters
            --enable-filter=*null*,afade,*fifo,*format,*resample,aeval,allrgb,allyuv,atempo,pan,*bars,color,*key,crop,draw*,eq*,framerate,*_qsv,*_vaapi,*v4l2*,hw*,scale,volume,test*
            --disable-protocols
            --enable-protocol=file,fd,pipe,http,https,rtp,tcp,udp
            --disable-muxers
            --enable-muxer=rtp
            --disable-encoders
            --disable-decoders
            --enable-decoder=*aac*,h264*,mp3*,mjpeg,rv*
            --disable-demuxers
            --enable-demuxer=h264,mp3,mov,mpjpeg,rtsp,sdp
            --disable-zlib
            --disable-avdevice
        BUILD_IN_SOURCE ON
        BUILD_COMMAND make ${_build_j}
        INSTALL_COMMAND make install
    )

endif()
