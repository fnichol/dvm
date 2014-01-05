# -*- mode: ruby -*-
# vi: set ft=ruby :
#
#  dvm - Effortless Docker-in-a-box for unsupported Docker platforms
#  For more details, please visit http://fnichol.github.io/dvm
#

port    = ENV.fetch("DOCKER_PORT", "5252")
memory  = ENV.fetch("DOCKER_MEMORY", "512")
args    = ENV.fetch("DOCKER_ARGS", "-H unix:///var/run/docker.sock -H tcp://0.0.0.0:#{port}")

Vagrant.configure("2") do |config|
  config.vm.box = "boot2docker"
  config.vm.box_url = "https://github.com/mitchellh/boot2docker-vagrant-box/releases/download/v0.3.0/boot2docker.box"
  config.vm.network "forwarded_port", guest: Integer(port), host: Integer(port)
  config.vm.provider :virtualbox do |v| v.memory = Integer(memory) end
  config.ssh.shell = "sh -l"
  config.vm.provision :shell, :inline => <<-PREPARE
    INITD=/usr/local/etc/init.d/docker
    if ! grep -q 'tcp://' $INITD >/dev/null; then
      echo "---> Configuring docker to bind to tcp/#{port} and restarting"
      sudo sed -i -e 's|docker -d|docker -d #{args}|' $INITD
      sudo $INITD restart
    fi
  PREPARE
  config.vm.define :dvm
end
