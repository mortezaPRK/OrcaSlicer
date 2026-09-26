/*
   BSD 2-Clause License (http://www.opensource.org/licenses/bsd-license.php)

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:

       * Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
       * Redistributions in binary form must reproduce the above
   copyright notice, this list of conditions and the following disclaimer
   in the documentation and/or other materials provided with the
   distribution.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

   You can contact the author at :
   - RygsDXTc source repository : http://code.google.com/p/rygsdxtc/

*/
#pragma once

#include <algorithm>
#include <cstddef>
#include <cstring>
#include "stb_dxt.h"

// Whole-image adapter retained from RygsDXTc. Repeat partial edge blocks using
// the original padding rule; each DXT5 block occupies 16 bytes, DXT1 8 bytes.
inline void rygCompress(unsigned char* dst, const unsigned char* src, int width, int height,
                        int is_dxt5, int& compressed_size)
{
    unsigned char block[64];
    compressed_size = 0;
    for (int y = 0; y < height; y += 4) {
        for (int x = 0; x < width; x += 4) {
            const int block_width = std::min(width - x, 4);
            const int block_height = std::min(height - y, 4);
            for (int row = 0; row < 4; ++row) {
                for (int col = 0; col < 4; ++col) {
                    const size_t source_pixel = size_t(y + row % block_height) * width + x + col % block_width;
                    std::memcpy(block + (row * 4 + col) * 4, src + source_pixel * 4, 4);
                }
            }
            stb_compress_dxt_block(dst + compressed_size, block, is_dxt5, STB_DXT_NORMAL);
            compressed_size += is_dxt5 ? 16 : 8;
        }
    }
}
