#include <catch2/catch_test_macros.hpp>
#include <imgui/imgui.h>
#include <imgui/imgui_internal.h>

namespace {
struct ImGuiTestContext {
    ImGuiContext* previous = ImGui::GetCurrentContext();
    ImGuiContext* context = ImGui::CreateContext();

    ImGuiTestContext()
    {
        ImGui::SetCurrentContext(context);
        auto& io = ImGui::GetIO();
        io.IniFilename = nullptr;
        io.DisplaySize = ImVec2(800, 600);
        io.Fonts->AddFontDefault();
    }
    ~ImGuiTestContext()
    {
        ImGui::DestroyContext(context);
        ImGui::SetCurrentContext(previous);
    }
};
}

TEST_CASE("ImGui keyboard events preserve presses and releases", "[ImGui]")
{
    ImGuiTestContext context;
    auto& io = ImGui::GetIO();
    REQUIRE(io.Fonts->Build());
    io.Fonts->SetTexID((ImTextureID)(intptr_t)1);
    for (int frame = 0; frame < 3; ++frame) {
        io.AddKeyEvent(ImGuiKey_LeftArrow, frame == 1);
        ImGui::NewFrame();
        REQUIRE(ImGui::IsKeyDown(ImGuiKey_LeftArrow) == (frame == 1));
        REQUIRE(ImGui::IsKeyPressed(ImGuiKey_LeftArrow, false) == (frame == 1));
        ImGui::Render();
    }
}

TEST_CASE("ImGui keeps custom icon rectangles and search highlight colors", "[ImGui]")
{
    ImGuiTestContext context;
    auto& io = ImGui::GetIO();
    const auto icon_id = io.Fonts->AddCustomRectFontGlyph(io.Fonts->Fonts[0], 0xe000, 16, 16, 20);
    REQUIRE(io.Fonts->Build());
    ImFontAtlasRect icon;
    REQUIRE(io.Fonts->GetCustomRect(icon_id, &icon));
    REQUIRE(icon.w == 16);
    REQUIRE(icon.h == 16);
    io.Fonts->SetTexID((ImTextureID)(intptr_t)1);

    ImGui::NewFrame();
    ImGui::SetNextWindowPos(ImVec2(0, 0));
    ImGui::SetNextWindowSize(ImVec2(400, 300));
    ImGui::Begin("highlight");
    ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(1, 0, 0, 1));
    ImGui::PushStyleColor(ImGuiCol_FrameBg, ImVec4(0, 1, 0, 1));
    const char marked[] = {ImGui::ColorMarkerHovered, ImGui::ColorMarkerStart, 'A', ImGui::ColorMarkerEnd, 'B', 0};
    auto* draw_list = ImGui::GetWindowDrawList();
    const int start = draw_list->VtxBuffer.Size;
    draw_list->AddText(ImVec2(20, 40), IM_COL32_WHITE, marked);
    REQUIRE(draw_list->VtxBuffer.Size - start == 8);
    REQUIRE(draw_list->VtxBuffer[start].col == IM_COL32(0, 255, 0, 255));
    REQUIRE(draw_list->VtxBuffer[start + 4].col == IM_COL32_WHITE);
    ImGui::PopStyleColor(2);
    ImGui::End();
    ImGui::Render();
}

TEST_CASE("ImGui menu layout does not highlight an unhovered item", "[ImGui][Regression]")
{
    ImGuiTestContext context;
    auto& io = ImGui::GetIO();
    REQUIRE(io.Fonts->Build());
    io.Fonts->SetTexID((ImTextureID)(intptr_t)1);
    ImGui::NewFrame();
    ImGui::SetNextWindowSize(ImVec2(400, 300));
    ImGui::Begin("menu");
    ImGui::PushStyleColor(ImGuiCol_HeaderHovered, ImVec4(1, 0, 0, 1));
    auto* draw_list = ImGui::GetWindowDrawList();
    const int start = draw_list->VtxBuffer.Size;
    REQUIRE_FALSE(ImGui::BBLMenuItem("item", nullptr, false, true, 24));
    for (int i = start; i < draw_list->VtxBuffer.Size; ++i)
        REQUIRE(draw_list->VtxBuffer[i].col != IM_COL32(255, 0, 0, 255));
    ImGui::PopStyleColor();
    ImGui::End();
    ImGui::Render();
}
