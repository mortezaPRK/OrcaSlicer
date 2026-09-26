find_package(Qhull 8.0 REQUIRED)

add_library(qhull INTERFACE)



if(SLIC3R_STATIC)
    slic3r_remap_configs("Qhull::qhullcpp;Qhull::qhullstatic_r" RelWithDebInfo Release)
    target_link_libraries(qhull INTERFACE Qhull::qhullcpp Qhull::qhullstatic_r)
else()
    slic3r_remap_configs("Qhull::qhullcpp;Qhull::qhull_r" RelWithDebInfo Release)
    target_link_libraries(qhull INTERFACE Qhull::qhullcpp Qhull::qhull_r)
endif()
