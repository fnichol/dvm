# -*- mode: ruby -*-
# vi: set ft=ruby :
#
#  dvm - Effortless Docker-in-a-box for unsupported Docker platforms
#  For more details, please visit http://fnichol.github.io/dvm
#

ip      = ENV.fetch("DOCKER_IP", "192.168.42.43")
port    = ENV.fetch("DOCKER_PORT", "4243")
memory  = ENV.fetch("DOCKER_MEMORY", "512")
args    = ENV.fetch("DOCKER_ARGS", "-H unix:///var/run/docker.sock -H tcp://0.0.0.0:#{port}")

module VagrantPlugins
  module GuestTcl
    module Cap ; end

    class Plugin < Vagrant.plugin("2")
      name "Core Linux guest"
      description "Core Linux guest support"

      guest("tcl", "linux") do
        class ::VagrantPlugins::GuestTcl::Guest < Vagrant.plugin("2", :guest)
          def detect?(machine)
            machine.communicate.test("cat /etc/issue | grep 'Core Linux'")
          end
        end
        Guest
      end

      guest_capability("tcl", "halt") do
        class ::VagrantPlugins::GuestTcl::Cap::Halt
          def self.halt(machine)
            machine.communicate.sudo("poweroff")
          rescue IOError
            # Do nothing, because it probably means the machine shut down
            # and SSH connection was lost.
          end
        end
        Cap::Halt
      end

      guest_capability("tcl", "configure_networks") do
        class ::VagrantPlugins::GuestTcl::Cap::ConfigureNetworks
          def self.configure_networks(machine, networks)
            require 'ipaddr'
            machine.communicate.tap do |comm|
              networks.each do |n|
                ifc = "/sbin/ifconfig eth#{n[:interface]}"
                broadcast = (IPAddr.new(n[:ip]) | (~ IPAddr.new(n[:netmask]))).to_s
                comm.sudo("#{ifc} down")
                comm.sudo("#{ifc} #{n[:ip]} netmask #{n[:netmask]} broadcast #{broadcast}")
                comm.sudo("#{ifc} up")
              end
            end
          end
        end
        Cap::ConfigureNetworks
      end
    end
  end
end

Vagrant.configure("2") do |config|
  config.vm.box = "boot2docker-0.3.0-1"
  config.vm.box_url = "https://github.com/mitchellh/boot2docker-vagrant-box/releases/download/v0.3.0-1/boot2docker.box"
  config.vm.network "private_network", :ip => ip
  config.vm.provider :virtualbox do |v| v.memory = Integer(memory) end
  config.vm.provision :shell, :inline => <<-PREPARE
    INITD=/usr/local/etc/init.d/docker
    if ! grep -q 'tcp://' $INITD >/dev/null; then
      echo "---> Configuring docker to bind to tcp/#{port} and restarting"
      sudo sed -i -e 's|docker -d|docker -d #{args}|' $INITD
      sudo $INITD restart
    fi
    if ! grep -q '8\.8\.8\.8' /etc/resolv.conf >/dev/null; then
      echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    fi
  PREPARE
  config.vm.define :dvm
end
