#!/usr/bin/env bash
set -euo pipefail

os=$1
action=$2
source_dir=$3
work_dir="$HOME/orca-work"
export CMAKE_BUILD_PARALLEL_LEVEL="${CMAKE_BUILD_PARALLEL_LEVEL:-2}"

if [[ "$os" == macos ]]; then
    [[ $(uname -s) == Darwin && $(uname -m) == arm64 ]]
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    mkdir -p "$source_dir"
    # Refresh virtiofs after host-side atomic replacements; macOS can retain
    # stale file handles even though directory listings show the new files.
    if mount | grep -Fq " on $source_dir "; then
        sudo umount "$source_dir"
    fi
    sudo mount_virtiofs orca "$source_dir"
else
    [[ $(uname -s) == Linux && $(uname -m) == aarch64 ]]
    sudo mkdir -p "$source_dir"
    if ! mountpoint -q "$source_dir"; then
        sudo mount -t virtiofs orca "$source_dir"
    fi
    if [[ "$action" == setup ]]; then
        sudo apt-get update
        sudo apt-get install -y rsync python3-venv
    fi
fi

mkdir -p "$work_dir"
# Keep source changes current while preserving this guest's build caches.
rsync -a --delete --exclude '/.vagrant/' --exclude '/.cache/' \
    --exclude '/build*/' --exclude '/deps/build*/' --exclude '/deps/DL_CACHE/' \
    --exclude '/deps_src/build/' "$source_dir/" "$work_dir/"
cd "$work_dir"

if [[ "$action" == setup ]]; then
    if [[ "$os" == macos ]]; then
        xcodebuild -version
        brew install cmake ninja automake autoconf texinfo libtool pkgconf yasm nasm ccache gettext
    else
        sudo ./build_linux.sh -ur
        python3 -m venv "$HOME/orca-tools"
        "$HOME/orca-tools/bin/pip" install 'cmake>=4.3,<5'
    fi
elif [[ "$action" == build ]]; then
    if [[ "$os" == macos ]]; then
        ./build_release_macos.sh -dx -a arm64 -j "$CMAKE_BUILD_PARALLEL_LEVEL"
        ./build_release_macos.sh -sxT -a arm64 -j "$CMAKE_BUILD_PARALLEL_LEVEL"
    else
        export PATH="$HOME/orca-tools/bin:$PATH"
        ./build_linux.sh -dstrlL -j "$CMAKE_BUILD_PARALLEL_LEVEL"
        ./scripts/run_unit_tests.sh build/tests Release
    fi
else
    echo "Unknown action: $action" >&2
    exit 2
fi
