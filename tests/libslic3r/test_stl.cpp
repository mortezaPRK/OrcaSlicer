#include <catch2/catch_all.hpp>
#include <string>
#include "libslic3r/Point.hpp"

#include <catch2/catch_test_macros.hpp>
#include "libslic3r/Model.hpp"
#include "libslic3r/Format/STL.hpp"

using namespace Slic3r;

static inline std::string stl_path(const char* path)
{
	return std::string(TEST_DATA_DIR) + "/test_stl/" + path;
}

SCENARIO("Reading an STL file", "[stl]") {
	GIVEN("umlauts in the path of a binary STL file, Czech characters in the file name") {
        WHEN("STL file is read") {
			Slic3r::Model model;
			THEN("load should succeed") {
                REQUIRE(Slic3r::load_stl(stl_path("Geräte/20mmbox-čřšřěá.stl").c_str(), &model));
				REQUIRE(is_approx(model.objects.front()->volumes.front()->mesh().size(), Vec3d(20, 20, 20)));
            }
        }
    }
	GIVEN("in ASCII format") {
		WHEN("line endings LF") {
			Slic3r::Model model;
			THEN("load should succeed") {
				REQUIRE(Slic3r::load_stl(stl_path("ASCII/20mmbox-LF.stl").c_str(), &model));
				REQUIRE(is_approx(model.objects.front()->volumes.front()->mesh().size(), Vec3d(20, 20, 20)));
			}
		}
		WHEN("line endings CRLF") {
			Slic3r::Model model;
			THEN("load should succeed") {
				REQUIRE(Slic3r::load_stl(stl_path("ASCII/20mmbox-CRLF.stl").c_str(), &model));
				REQUIRE(is_approx(model.objects.front()->volumes.front()->mesh().size(), Vec3d(20, 20, 20)));
			}
		}
#if 0
		// ASCII STLs ending with just carriage returns are not supported. These were used by the old Macs, while the Unix based MacOS uses LFs as any other Unix.
		WHEN("line endings CR") {
			Slic3r::Model model;
			THEN("load should succeed") {
				REQUIRE(Slic3r::load_stl(stl_path("ASCII/20mmbox-CR.stl").c_str(), &model));
				REQUIRE(is_approx(model.objects.front()->volumes.front()->mesh().size(), Vec3d(20, 20, 20)));
			}
		}

#endif
		WHEN("nonstandard STL file (text after ending tags, invalid normals, for example infinities)") {
			Slic3r::Model model;
			THEN("load should succeed") {
				REQUIRE(Slic3r::load_stl(stl_path("ASCII/20mmbox-nonstandard.stl").c_str(), &model));
				REQUIRE(is_approx(model.objects.front()->volumes.front()->mesh().size(), Vec3d(20, 20, 20)));
			}
		}
	}
}

TEST_CASE("Normal repair ignores out-of-range facet neighbors", "[Stl][Regression]")
{
    const int neighbor = GENERATE(-2, 1, 1000000);
    const bool reversed = GENERATE(false, true);
    stl_file mesh;
    mesh.stats.number_of_facets = 1;
    mesh.facet_start.resize(1);
    mesh.neighbors_start.resize(1);
    auto &facet = mesh.facet_start.front();
    facet.vertex[0] = stl_vertex(0, 0, 0);
    facet.vertex[1] = stl_vertex(1, 0, 0);
    facet.vertex[2] = stl_vertex(0, 1, 0);
    facet.normal = stl_normal(0, 0, reversed ? -1 : 1);
    mesh.neighbors_start[0].neighbor[0] = neighbor;
    mesh.neighbors_start[0].which_vertex_not[0] = 3;

    stl_fix_normal_directions(&mesh);

    REQUIRE(mesh.stats.number_of_parts == 1);
    REQUIRE(mesh.facet_start.size() == 1);
}
