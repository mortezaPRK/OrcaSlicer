# Vagrant 2.4.9's bundled Ruby can return an unconnected Socket.tcp on newer
# macOS hosts. Verify the peer before declaring a forwarded port occupied.
require "vagrant/util/is_port_open"

module OrcaVagrantPortCheck
  def is_port_open?(host, port)
    socket = Socket.tcp(host, port, connect_timeout: 0.1)
    socket.remote_address
    true
  rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::EHOSTUNREACH,
         Errno::ENETUNREACH, Errno::EACCES, Errno::ENOTCONN, Errno::EALREADY,
         Errno::EINVAL
    false
  ensure
    socket&.close
  end
end

Vagrant::Util::IsPortOpen.singleton_class.prepend(OrcaVagrantPortCheck)
