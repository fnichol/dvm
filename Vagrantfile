# -*- mode: ruby -*-
# vi: set ft=ruby :
#
#  dvm - Effortless Docker-in-a-box for unsupported Docker platforms
#  For more details, please visit http://fnichol.github.io/dvm
#

def shq(s)  # sh(1)-style quoting
  sprintf("'%s'", s.gsub(/'/, "'\\\\''"))
end

ip      = ENV.fetch("DOCKER_IP", "192.168.42.43")
port    = ENV.fetch("DOCKER_PORT", "4243")
memory  = ENV.fetch("DOCKER_MEMORY", "512")
cpus    = ENV.fetch("DOCKER_CPUS", "1")
cidr    = ENV.fetch("DOCKER0_CIDR", "")
args    = ENV.fetch("DOCKER_ARGS", "")

docker0_bridge_setup = ""
bridge_utils_url     = "ftp://ftp.nl.netbsd.org/vol/2/metalab/distributions/tinycorelinux/4.x/x86/tcz/bridge-utils.tcz"
unless cidr.empty?
  args += " --bip=#{cidr}"

  as_docker_usr     = 'su - docker -c'
  dl_dir            = '/home/docker'
  filename          = 'bridge-utils.tcz'
  dl_br_utils       = "wget -P #{dl_dir} -O #{filename} #{shq(bridge_utils_url)}"
  install_br_utils  = "tce-load -i #{dl_dir}/#{filename}"
  brctl             = '/usr/local/sbin/brctl'
  ifcfg             = '/sbin/ifconfig'
  take_docker0_down = "#{ifcfg} docker0 down"
  delete_docker0    = "#{brctl} delbr docker0"

  docker0_bridge_setup = <<-BRIDGE_SETUP
    sudo $INITD stop
    echo #{shq("#{as_docker_usr} #{shq(dl_br_utils)}")}
    #{as_docker_usr} #{shq(dl_br_utils)}
    echo #{shq("#{as_docker_usr} #{shq(install_br_utils)}")}
    #{as_docker_usr} #{shq(install_br_utils)}
    sudo #{take_docker0_down}
    sudo #{delete_docker0}
  BRIDGE_SETUP
end

def tinycore_supported?
  Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new("1.5.0")
end

module VagrantPlugins
  module GuestTinyCore
    module Cap ; end

    class Plugin < Vagrant.plugin("2")
      name "TinyCore Linux guest."
      description "TinyCore Linux guest support."

      if !tinycore_supported?
        guest("tinycore", "linux") do
          class ::VagrantPlugins::GuestTinyCore::Guest < Vagrant.plugin("2", :guest)
            def detect?(machine)
              machine.communicate.test("cat /etc/issue | grep 'Core Linux'")
            end
          end
          Guest
        end
      end

      if !tinycore_supported?
        guest_capability("tinycore", "halt") do
          class ::VagrantPlugins::GuestTinyCore::Cap::Halt
            def self.halt(machine)
              machine.communicate.sudo("poweroff")
            rescue IOError
              # Do nothing, because it probably means the machine shut down
              # and SSH connection was lost.
            end
          end
          Cap::Halt
        end
      end

      guest_capability("tinycore", "configure_networks") do
        class ::VagrantPlugins::GuestTinyCore::Cap::ConfigureNetworks
          def self.configure_networks(machine, networks)
            require 'ipaddr'
            machine.communicate.tap do |comm|
              networks.each do |n|
                ifc = "/sbin/ifconfig eth#{n[:interface]}"
                pid = "/var/run/udhcpc.eth#{n[:interface]}.pid"
                broadcast = (IPAddr.new(n[:ip]) | (~ IPAddr.new(n[:netmask]))).to_s
                comm.sudo("#{ifc} down")
                comm.sudo("if [ -f #{pid} ]; then kill `cat #{pid}` && rm -f #{pid}; fi")
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
  config.vm.box = "boot2docker-0.8.0"
  config.vm.network "private_network", :ip => ip

  config.vm.provider :virtualbox do |v, override|
    override.vm.box_url = "https://github.com/mitchellh/boot2docker-vagrant-box/releases/download/v0.8.0/boot2docker_virtualbox.box"
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--memory", Integer(memory)]
    v.customize ["modifyvm", :id, "--cpus", Integer(cpus)]
  end

  ["vmware_fusion", "vmware_workstation"].each do |vmware|
    config.vm.provider vmware do |v, override|
      override.vm.box_url = "https://github.com/mitchellh/boot2docker-vagrant-box/releases/download/v0.8.0/boot2docker_vmware.box"
      v.vmx["memsize"] = Integer(memory)
      v.vmx["numvcpus"] = Integer(cpus)
    end
  end

  args = "export EXTRA_ARGS=#{shq(args.strip)}" unless args.empty?

  config.vm.provision :shell, :inline => <<-PREPARE
    INITD=/usr/local/etc/init.d/docker
    #{docker0_bridge_setup}
    if [ #{port} -ne '4243' ]; then
      echo "---> Configuring docker to listen on port '#{port}' and restarting"
      sudo sed -i -e 's|\\(DOCKER_HOST="-H tcp://0.0.0.0:\\)4243|\\1#{port}|' $INITD
      sudo $INITD restart
    fi
    if [ -n #{shq(args)} ]; then
      echo '---> Configuring docker with args "'#{shq(args)}'" and restarting'
      echo #{shq(args)} > /var/lib/boot2docker/profile
      sudo $INITD restart
    fi
    if ! grep -q '8\.8\.8\.8' /etc/resolv.conf >/dev/null; then
      echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    fi
  PREPARE
  config.vm.define :dvm
end
