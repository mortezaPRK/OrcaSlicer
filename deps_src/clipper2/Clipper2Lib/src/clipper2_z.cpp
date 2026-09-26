// Hackish wrapper around the ClipperLib library to compile the Clipper library with the Z support.
// Enable the Z coordinate support.
#define USINGZ
#define Clipper2Lib Clipper2Lib_Z

// and let it compile
#include "clipper.engine.cpp"
#include "clipper.offset.cpp"
#include "clipper.rectclip.cpp"
#include "clipper.triangulation.cpp"
