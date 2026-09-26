# ARM64 build guests

The root Vagrantfile provides Linux and macOS guests through Tart, and a
Windows 11 ARM64 guest through VirtualBox. The host is an Apple Silicon Mac.
Compilation and tests run in guest-local directories. Linux and macOS receive
a read-only source mount; Windows receives an archive of tracked and unignored
working-tree files, including uncommitted edits.
Windows archive transfers use VirtualBox Guest Additions.

Install the host tools with Homebrew:

```sh
brew install cirruslabs/cli/tart
brew install --cask vagrant virtualbox
vagrant plugin install vagrant-tart
```

Each guest defaults to four CPUs and 8 GiB RAM. Set `ORCA_VM_CPUS` and
`ORCA_VM_MEMORY` to override these values. Allow enough disk space for the
guest images, toolchains, and independent dependency builds. Run builds one
at a time on hosts with limited RAM or disk space.

## Linux and macOS

```sh
scripts/vagrant/run.sh linux up
scripts/vagrant/run.sh linux build
scripts/vagrant/run.sh macos up
scripts/vagrant/run.sh macos build
```

The default images are Cirrus Labs Ubuntu 24.04 and macOS Tahoe with Xcode.
Override them with `ORCA_LINUX_IMAGE` and `ORCA_MACOS_IMAGE`, including a digest
when a fixed image revision is needed. Setup installs build tools; `build`
synchronizes source, builds dependencies and OrcaSlicer, and runs unit tests.
Source and build files live under `~/orca-work` in each guest.

## Windows

Download an ISO from [Microsoft's Windows 11 ARM64 page](https://www.microsoft.com/en-us/software-download/windows11arm64)
and verify its SHA256 against the checksum shown for the selected language.
Create a local box:

```sh
python3 scripts/vagrant/windows-box.py install /absolute/path/to/windows11-arm64.iso
# Wait for installation to finish and the base VM to shut down.
python3 scripts/vagrant/windows-box.py package
scripts/vagrant/run.sh windows up
scripts/vagrant/run.sh windows build
```

The installer defaults to image index 3 (Windows Pro). Check the edition list
printed by `VBoxManage unattended detect --iso=/path/to/iso` and pass
`--image-index` if the ISO uses a different ordering. The base VM is named
`orca-windows11-arm64-base`; packaging registers `orca/windows11-arm64` locally.
An existing compatible box can be selected with `ORCA_WINDOWS_BOX` instead.

The local test box uses the Vagrant development account and WinRM over NAT.
Keep it private. Provisioning installs Visual Studio Build Tools, clang-cl,
CMake, Perl, and Git without interactive prompts. Source lives in
`C:\orca-work`; build caches live separately in `C:\orca-build` and
`C:\orca-deps` so source synchronization preserves them.
Installer and build logs live in `C:\orca-logs`; the runner copies completed
logs to `.vagrant/logs/windows-setup-guest.log` and `windows-build-guest.log`.

## Guest management

```sh
scripts/vagrant/run.sh linux ssh
scripts/vagrant/run.sh macos halt
vagrant winrm windows -c 'Get-ComputerInfo -Property OsArchitecture'
vagrant provision windows --provision-with setup
```

Use `vagrant provision <guest> --provision-with setup` to repeat toolchain setup.
The build action refreshes source automatically. VM state, source archives,
installation media and boxes under `.vagrant/` are ignored by Git.
