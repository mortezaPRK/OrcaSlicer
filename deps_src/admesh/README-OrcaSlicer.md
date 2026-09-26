This is OrcaSlicer's C++/Eigen fork of ADMesh, not an unmodified upstream
release. It uses vector-owned facets, Orca's mesh statistics and repair
behavior, and the application's STL I/O and progress callbacks.

The upstream v0.98.5 normal-repair neighbor bounds check is retained in
`normals.cpp`, including the corresponding reverse-facet accesses. Upstream's
Autotools distribution changes do not apply to this CMake-built fork.

Upstream: https://github.com/admesh/admesh/releases/tag/v0.98.5
