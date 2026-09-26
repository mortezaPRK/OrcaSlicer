
if (WIN32)
    set(HIDAPI_IMPL win/hid.c)
elseif (APPLE)
    set(HIDAPI_IMPL mac/hid.c)
else ()
    # Assume Linux or Unix other than Mac OS
    set(HIDAPI_IMPL linux/hid.c)
endif()

include_directories(include)

add_library(hidapi STATIC ${HIDAPI_IMPL})
target_include_directories(hidapi SYSTEM
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    )

if (WIN32)
    target_compile_definitions(hidapi PUBLIC HID_API_NO_EXPORT_DEFINE)
elseif (APPLE)
    target_link_libraries(hidapi PRIVATE Threads::Threads "-framework IOKit" "-framework CoreFoundation")
elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    # libudev.so.0 or libudev.so.1 is loaded at runtime.
    target_link_libraries(hidapi PRIVATE Threads::Threads ${CMAKE_DL_LIBS})
endif()
