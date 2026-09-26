#!/usr/bin/env python3
"""Create a local Windows ARM64 Vagrant box from an official installation ISO."""
import argparse
import base64
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
NAME = "orca-windows11-arm64-base"


def run(*args):
    subprocess.run(args, cwd=ROOT, check=True)


parser = argparse.ArgumentParser(description=__doc__)
commands = parser.add_subparsers(dest="action", required=True)
install = commands.add_parser("install", help="Create the base VM and start installation")
install.add_argument("iso", type=Path)
install.add_argument("--image-index", type=int, default=3, help="Windows Pro image index")
commands.add_parser("package", help="Package the shut-down, fully installed base VM")
args = parser.parse_args()

if args.action == "install":
    iso = args.iso.resolve(strict=True)
    directory = ROOT / ".vagrant/windows-base"
    directory.mkdir(parents=True, exist_ok=True)
    disk = directory / NAME / "system.vdi"
    run("VBoxManage", "unattended", "detect", f"--iso={iso}")
    run("VBoxManage", "createvm", f"--name={NAME}", "--platform-architecture=arm",
        "--ostype=Windows11_arm64", f"--basefolder={directory}", "--default", "--register")
    run("VBoxManage", "modifyvm", NAME, "--memory=8192", "--cpus=4", "--tpm-type=2.0",
        "--boot1=dvd", "--boot2=disk", "--boot3=none")
    run("VBoxManage", "createmedium", "disk", f"--filename={disk}", "--size=163840", "--format=VDI")
    run("VBoxManage", "storageattach", NAME, "--storagectl=SATA", "--port=0", "--device=0",
        "--type=hdd", f"--medium={disk}")
    script = (ROOT / "scripts/vagrant/windows-base.ps1").read_text()
    encoded = base64.b64encode(script.encode("utf-16le")).decode("ascii")
    command = f"powershell.exe -NoProfile -ExecutionPolicy Bypass -EncodedCommand {encoded}"
    run("VBoxManage", "unattended", "install", NAME, f"--iso={iso}", "--user=vagrant",
        "--user-password=vagrant", "--admin-password=vagrant", "--full-user-name=Vagrant",
        "--install-additions", "--locale=en_US", "--country=US", "--time-zone=UTC",
        "--hostname=orca-windows.local", f"--image-index={args.image_index}",
        f"--post-install-command={command}", "--start-vm=headless")
    print("Installation shuts down the base VM when WinRM is ready. Then run the package command.")
else:
    state = subprocess.check_output(["VBoxManage", "showvminfo", NAME, "--machinereadable"], text=True)
    if 'VMState="poweroff"' not in state:
        parser.error("The base VM must finish installation and shut down before packaging.")
    run("VBoxManage", "storageattach", NAME, "--storagectl=SATA", "--port=1", "--device=0",
        "--type=dvddrive", "--medium=none")
    run("VBoxManage", "modifyvm", NAME, "--boot1=disk", "--boot2=none")
    box = ROOT / ".vagrant/windows11-arm64.box"
    run("vagrant", "package", "--base", NAME, "--output", str(box))
    run("vagrant", "box", "add", "--name", "orca/windows11-arm64", "--provider", "virtualbox",
        "--architecture", "arm64", str(box))
