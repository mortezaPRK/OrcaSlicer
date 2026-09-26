#include <catch2/catch_test_macros.hpp>
#include <catch2/generators/catch_generators.hpp>

#include <stb_dxt/ryg_dxt.h>
#include <array>
#include <vector>

TEST_CASE("DXT5 compression preserves solid colors in partial blocks", "[TextureCompression]")
{
    const auto size = GENERATE(std::array<int, 2>{1, 1}, std::array<int, 2>{1, 33},
                              std::array<int, 2>{33, 1}, std::array<int, 2>{3, 5},
                              std::array<int, 2>{8, 8});
    const int width = size[0], height = size[1];
    std::vector<unsigned char> pixels(size_t(width) * height * 4);
    for (size_t i = 0; i < pixels.size(); i += 4) {
        pixels[i] = 255;
        pixels[i + 3] = 128;
    }
    const size_t bytes = size_t((width + 3) / 4) * ((height + 3) / 4) * 16;
    std::vector<unsigned char> compressed(bytes + 16, 0xa5);
    int written = 0;
    rygCompress(compressed.data(), pixels.data(), width, height, 1, written);
    REQUIRE(written == bytes);
    for (size_t i = bytes; i < compressed.size(); ++i) REQUIRE(compressed[i] == 0xa5);

    // Decode the first pixel of each block using the DXT5 RGB565 palette.
    for (size_t offset = 0; offset < bytes; offset += 16) {
        const auto* block = compressed.data() + offset;
        REQUIRE(block[0] == 128);
        REQUIRE(block[1] == 128);
        unsigned colors[4][3]{};
        for (int endpoint = 0; endpoint < 2; ++endpoint) {
            const unsigned packed = block[8 + endpoint * 2] | (unsigned(block[9 + endpoint * 2]) << 8);
            colors[endpoint][0] = ((packed >> 11) & 31) * 255 / 31;
            colors[endpoint][1] = ((packed >> 5) & 63) * 255 / 63;
            colors[endpoint][2] = (packed & 31) * 255 / 31;
        }
        for (int channel = 0; channel < 3; ++channel) {
            colors[2][channel] = (2 * colors[0][channel] + colors[1][channel]) / 3;
            colors[3][channel] = (colors[0][channel] + 2 * colors[1][channel]) / 3;
        }
        const auto& color = colors[block[12] & 3];
        REQUIRE(color[0] >= 247);
        REQUIRE(color[1] <= 8);
        REQUIRE(color[2] <= 8);
    }
}
