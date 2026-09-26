# libigl in OrcaSlicer.

> [!NOTE]
> This is not the complete libigl distribution! Only the files needed for
> compiling libigl into OrcaSlicer are included in the OrcaSlicer source
> distribution. The full libigl distribution can be found at;
>
> https://github.com/libigl/libigl

This directory contains parts of the libigl v2.6.4 source
distribution together with a minimal custom `CMakeLists.txt` file. In
particular only the following files from the full libigl distribution are
included;

* README.md
* include/igl/* -> igl/*

The CGAL adapter uses the explicit `AABB_traits_3` and
`AABB_triangle_primitive_3` names for CGAL 6 compatibility.
