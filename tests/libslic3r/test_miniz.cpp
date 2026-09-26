#include <catch2/catch_test_macros.hpp>
#include <catch2/generators/catch_generators.hpp>
#include <miniz.h>

#include <cstring>
#include <memory>

TEST_CASE("Streamed ZIP entries preserve binary data and Unicode names", "[Miniz]")
{
    const mz_uint64 max_size = GENERATE(mz_uint64(4096), mz_uint64(1) << 34);
    const char payload[] = "streamed\0binary\r\n3mf payload";
    const char extra[] = {0x75, 0x70, 6, 0, 1, 0, 0, 0, 0, 'x'};
    mz_zip_archive writer{};
    REQUIRE(mz_zip_writer_init_heap(&writer, 0, 0));
    auto end_writer = [](mz_zip_archive *zip) { mz_zip_writer_end(zip); };
    std::unique_ptr<mz_zip_archive, decltype(end_writer)> writer_guard(&writer, end_writer);

    mz_zip_writer_staged_context context{};
    REQUIRE(mz_zip_writer_add_staged_open(&writer, &context, u8"模型.model", max_size,
        nullptr, nullptr, 0, 6, extra, sizeof(extra), extra, sizeof(extra)));
    REQUIRE(mz_zip_writer_add_staged_data(&context, payload, 8));
    REQUIRE(mz_zip_writer_add_staged_data(&context, payload + 8, sizeof(payload) - 8));
    REQUIRE(mz_zip_writer_add_staged_finish(&context));

    void *buffer = nullptr;
    size_t size = 0;
    REQUIRE(mz_zip_writer_finalize_heap_archive(&writer, &buffer, &size));
    std::unique_ptr<void, decltype(&mz_free)> buffer_guard(buffer, mz_free);
    mz_zip_archive reader{};
    REQUIRE(mz_zip_reader_init_mem(&reader, buffer, size, 0));
    auto end_reader = [](mz_zip_archive *zip) { mz_zip_reader_end(zip); };
    std::unique_ptr<mz_zip_archive, decltype(end_reader)> reader_guard(&reader, end_reader);

    mz_zip_archive_file_stat stat{};
    REQUIRE(mz_zip_reader_file_stat(&reader, 0, &stat));
    CHECK(stat.m_is_utf8);
    CHECK(std::strcmp(stat.m_filename, u8"模型.model") == 0);
    char extracted[sizeof(payload)]{};
    REQUIRE(mz_zip_reader_extract_to_mem(&reader, 0, extracted, sizeof(extracted), 0));
    CHECK(std::memcmp(payload, extracted, sizeof(payload)) == 0);
    char extras[sizeof(extra) + 1]{};
    REQUIRE(mz_zip_reader_get_extra(&reader, 0, extras, sizeof(extras)) == sizeof(extras));
    CHECK(std::memcmp(extra, extras, sizeof(extra)) == 0);
}
