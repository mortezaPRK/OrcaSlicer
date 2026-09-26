This is OrcaSlicer's libnest2d fork. The latest upstream tagged release is
0.4 (`85d66c7a3b89cbd1eba61251b135d968b92bedd9`). Orca maintains its own
libslic3r geometry backend, arrangement rules, calibration-area handling and
placement fixes here; replacing it with that upstream release would remove
application behavior.

The fork is exercised by the `libnest2d_tests` target and the arrangement tests
in `libslic3r_tests`.

Upstream: https://github.com/tamasmeszaros/libnest2d/tree/0.4
