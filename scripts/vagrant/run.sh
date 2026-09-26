#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
os=${1:?Usage: scripts/vagrant/run.sh linux|macos|windows up|build|halt|ssh}
action=${2:-up}
case "$os" in
    linux|macos) provider=tart ;;
    windows) provider=virtualbox ;;
    *) echo "Unknown guest: $os" >&2; exit 2 ;;
esac
case "$action" in
    up|build|halt|ssh) ;;
    *) echo "Unknown action: $action" >&2; exit 2 ;;
esac
if [[ "$os" == windows && ( "$action" == up || "$action" == build ) ]]; then
    mkdir -p .vagrant
    python3 - <<'PY'
import os
import subprocess
import tarfile

paths = subprocess.check_output([
    'git', 'ls-files', '--cached', '--others', '--exclude-standard', '-z'
]).split(b'\0')
with tarfile.open('.vagrant/orca-source.tar', 'w') as archive:
    for raw_path in sorted(set(paths)):
        path = os.fsdecode(raw_path)
        if path and os.path.lexists(path):
            archive.add(path, arcname=path, recursive=False)
PY
    vagrant up windows --provider=virtualbox --no-provision
    windows_id=$(cat .vagrant/machines/windows/virtualbox/id)
    VBoxManage guestcontrol "$windows_id" copyto --username=vagrant --password=vagrant \
        --target-directory=C:/Users/vagrant/orca-source.tar .vagrant/orca-source.tar
    provision_windows() {
        local stage=$1 result=0
        vagrant provision windows --provision-with "$stage" || result=$?
        mkdir -p .vagrant/logs
        VBoxManage guestcontrol "$windows_id" copyfrom --username=vagrant --password=vagrant \
            "C:/orca-logs/$stage.log" ".vagrant/logs/windows-$stage-guest.log" || true
        return "$result"
    }
    setup_marker=.vagrant/machines/windows/virtualbox/orca_toolchain_ready
    if [[ ! -f "$setup_marker" || "$(cat "$setup_marker")" != "$windows_id" ]]; then
        provision_windows setup
        printf '%s\n' "$windows_id" > "$setup_marker"
    fi
    if [[ "$action" == build ]]; then
        provision_windows build
    fi
    exit
fi
case "$action" in
    up) vagrant up "$os" --provider="$provider" ;;
    build)
        vagrant up "$os" --provider="$provider"
        vagrant provision "$os" --provision-with build
        ;;
    *) vagrant "$action" "$os" ;;
esac
