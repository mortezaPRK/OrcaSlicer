# ARM64 test guests. See scripts/vagrant/README.md.
require "digest"
if RUBY_PLATFORM.include?("darwin") && Vagrant::VERSION == "2.4.9"
  require_relative "scripts/vagrant/port_check"
end

Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.boot_timeout = 900
  suffix = Digest::SHA256.hexdigest(File.realpath(__dir__))[0, 8]
  cpus = Integer(ENV.fetch("ORCA_VM_CPUS", "4"))
  memory = Integer(ENV.fetch("ORCA_VM_MEMORY", "8192"))

  { "linux" => "ghcr.io/cirruslabs/ubuntu:24.04",
    "macos" => "ghcr.io/cirruslabs/macos-tahoe-xcode:latest" }.each do |os, image|
    config.vm.define os, autostart: false do |guest|
      guest.vm.guest = os == "macos" ? :darwin : :linux
      guest.ssh.username = "admin"
      guest.ssh.password = "admin"
      guest.vm.provider :tart do |provider|
        provider.image = ENV.fetch("ORCA_#{os.upcase}_IMAGE", image)
        provider.name = "orca-#{os}-#{suffix}"
        provider.cpus = cpus
        provider.memory = memory
        provider.disk = os == "macos" ? 180 : 120
        provider.gui = false
      end
      source = os == "macos" ? "/Users/admin/orca-source" : "/mnt/orca"
      guest.vm.synced_folder __dir__, source, type: :tart,
                            mount_options: ["tag=orca", "mode=ro"]
      guest.vm.provision "setup", type: "shell", privileged: false,
                         path: "scripts/vagrant/unix.sh", args: [os, "setup", source]
      guest.vm.provision "build", type: "shell", run: "never", privileged: false,
                         path: "scripts/vagrant/unix.sh", args: [os, "build", source]
    end
  end

  config.vm.define "windows", autostart: false do |guest|
    # Register an ARM64 Windows box with WinRM enabled under this name, or
    # supply a provider-compatible box through ORCA_WINDOWS_BOX.
    guest.vm.box = ENV.fetch("ORCA_WINDOWS_BOX", "orca/windows11-arm64")
    guest.vm.box_architecture = "arm64"
    guest.vm.guest = :windows
    guest.vm.communicator = :winrm
    guest.vm.provider :virtualbox do |provider|
      provider.cpus = cpus
      provider.memory = memory
      provider.gui = true
    end
    # The runner transfers the working tree through Guest Additions before
    # provisioning; WinRM's file transport is too slow for the source archive.
    guest.vm.provision "setup", type: "shell", path: "scripts/vagrant/windows.ps1",
                       args: ["-Action", "setup"]
    guest.vm.provision "build", type: "shell", run: "never",
                       path: "scripts/vagrant/windows.ps1", args: ["-Action", "build"]
  end
end
