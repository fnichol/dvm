# dvm

An on demand [Docker][docker] virtual machine, thanks to [Vagrant][vagrant] and [boot2docker][boot2docker]. Works great on Macs and other platforms that don't natively support the Docker daemon. Under the covers this is downloading and booting Mitchell Hashimoto's [boot2docker Vagrant Box][boot2docker_vagrant_box] image.

The driving need for something like dvm was for running infrastructure testing, like [Test Kitchen][kitchenci] using the [kitchen-docker driver][kitchen_docker]. For the driver to work it needs access to all the dynamically assigned ports, not just the Docker daemon port. That's why dvm uses a private network segment and address (`192.168.42.43` by default). Once Docker started supporting the `DOCKER_HOST` environment variable, the actual IP address was less important and consequently made the docker command on non-Linux distros feel almost native.

## <a name="mac-tl-dr"></a> tl;dr for Mac Users

Are you already a Vagrant user using Virtualbox? Use Homebrew? Great!


```sh
# Install Docker Mac binary
brew install docker

# Install dvm
brew tap fnichol/dvm
brew install dvm

# Bring up your Vagrant/Docker VM
dvm up

# Set a DOCKER_HOST environment variable that points to your VM
eval $(dvm env)

# Run plain 'ol Docker commands right from your Mac
docker run ubuntu cat /etc/lsb-release
```

p.s. No Vagrant or VirtualBox installed? Check out the [Requirements](#requirements) section below.

## <a name="requirements"></a> Requirements

* [VirtualBox][virtualbox_dl], version 4.3.4+, [VMware Fusion][vmware_fusion_dl]/[VMware Workstation][vmware_workstation_dl], or [Parallels Desktop][parallels_dl]
* [Vagrant][vagrant_dl], version 1.4.0+
* (*Optional*) [Docker][docker_dl], version 0.7.3+ or use the [Docker Remote API][docker_api]

Use [Homebrew Cask](https://github.com/phinze/homebrew-cask)? For Vagrant and VirtualBox, too easy!

```sh
brew cask install vagrant    --appdir=/Applications
brew cask install virtualbox --appdir=/Applications
```

## <a name="install"></a> Install

Installation is supported for any Unixlike platform that Vagrant and VirtualBox/VMware support.

```sh
wget -O dvm-0.9.0.tar.gz https://github.com/fnichol/dvm/archive/v0.9.0.tar.gz
tar -xzvf dvm-0.9.0.tar.gz
cd dvm-0.9.0/
sudo make install
```

### <a name="install-homebrew"></a> Installing with Homebrew (Mac)

There is a [Homebrew tap][homebrew_dvm] with a formula which can be installed with:

```sh
brew tap fnichol/dvm
brew install dvm
```

## <a name="upgrade"></a> Upgrade

You can follow the instructions for [installing](#install) dvm.

Please note however that if the underlying boot2docker basebox is upgraded between versions, you will effectively get a new virtual machine when dvm restarts. A good idea before upgrading is to destroy your current dvm instance with `dvm destroy`.

### <a name="upgrade-homebrew"></a> Upgrading with Homebrew (Mac)

If using the dvm Homebrew tap, simply:

```sh
brew update
brew upgrade dvm
```

Also please read the above note about destroying in between upgrades.

## <a name="usage"></a> Usage

Bring up help with:

```
$ dvm --help

Usage: dvm [-v|-h] command [<args>]

Options

  --version, -v - Print the version and exit
  --help, -h    - Display CLI help (this output)

Commands

  check           Ensure that required software is installed and present
  destroy         Stops and deletes all traces of the vagrant machine
  env             Outputs environment variables for Docker to connect remotely
  halt, stop      Stops the vagrant machine
  ip              Outputs the IP address of the vagrant machine
  reload          Restarts vagrant machine, loads new configuration
  resume          Resume the suspended vagrant machine
  ssh             Connects to the machine via SSH
  status          Outputs status of the vagrant machine
  suspend, pause  Suspends the machine
  up, start       Starts and provisions the vagrant environment
  vagrant         Issue subcommands directly to the vagrant CLI
```

Keep in mind that dvm thinly wraps Vagrant so don't hesitate to use raw Vagrant commands in your `$HOME/.dvm` directory. Or use the `dvm vagrant` subcommand from anywhere:

```
$ dvm vagrant --version
Vagrant 1.5.2
```

Bring up your VM with `dvm up`:

```
$ dvm up
Bringing machine 'dvm' up with 'virtualbox' provider...
...<snip>...
==> dvm: Configuring and enabling network interfaces...
==> dvm: Running provisioner: shell...
    dvm: Running: inline script
```

Or maybe you want to use the `vmware_fusion` Vagrant provider which isn't your default?

```
$ dvm up --provider=vmware_fusion
```

Need to free up some memory? Pause your VM with `dvm suspend`:

```
$ dvm suspend
==> dvm: Saving VM state and suspending execution...
```

When you come back to your awesome Docker project, resume your VM with `dvm resume`:

```
$ dvm resume
==> dvm: Resuming suspended VM...
==> dvm: Booting VM...
==> dvm: Waiting for machine to boot. This may take a few minutes...
    dvm: SSH address: 127.0.0.1:2222
    dvm: SSH username: docker
    dvm: SSH auth method: private key
    dvm: Warning: Connection refused. Retrying...
==> dvm: Machine booted and ready!
```

Your local `docker` binary needs to be told that it is targetting a remote system and to not try the local Unix socket, which is the default behavior. Version 0.7.3 of Docker introduced the `DOCKER_HOST` environment variable that will set the target Docker host. By default, dvm will run your VM on a private network at **192.168.42.43** with Docker listening on port **2375**. The `dvm env` subcommand will print a suitable `DOCKER_HOST` line that can be used in your environment. If you want this loaded into your session, evaluate the resulting config with:

```
$ echo $DOCKER_HOST

$ eval `dvm env`

$ echo $DOCKER_HOST
tcp://192.168.42.43:2375
```

Check your VM status with `dvm status`:

```
$ dvm status
Current machine states:

dvm                       running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.
```

Log into your VM (via SSH) with `dvm ssh`:

```
$ dvm ssh
                        ##        .
                  ## ## ##       ==
               ## ## ## ##      ===
           /""""""""""""""""\___/ ===
      ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
           \______ o          __/
             \    \        __/
              \____\______/
 _                 _   ____     _            _
| |__   ___   ___ | |_|___ \ __| | ___   ___| | _____ _ __
| '_ \ / _ \ / _ \| __| __) / _` |/ _ \ / __| |/ / _ \ '__|
| |_) | (_) | (_) | |_ / __/ (_| | (_) | (__|   <  __/ |
|_.__/ \___/ \___/ \__|_____\__,_|\___/ \___|_|\_\___|_|
boot2docker: 1.0.0
             master : 16013ee - Mon Jun  9 16:33:25 UTC 2014
docker@boot2docker:~$
```

## <a name="usage-embedded"></a> Embed in a Project

As the core of dvm is a Vagrantfile (surprise!), you can simply download the dvm Vagrantfile into your project using the http://git.io/dvm-vagrantfile shortlink:

```sh
wget -O Vagrantfile http://git.io/dvm-vagrantfile
```

## <a name="configuration"></a> Configuration

If you wish to change the Docker TCP port or memory settings of the virtual machine, edit `$HOME/.dvm/dvm.conf` for the configuration to be used. By default the following configuration is used:

* `DOCKER_IP`: `192.168.42.43`
* `DOCKER_PORT`: `2375`
* `DOCKER_MEMORY`: `512` (in MB)
* `DOCKER_CPUS`: `1`
* `DOCKER_ARGS`: `-H unix:// -H tcp://`

If you wish to change the network range Docker uses for the `docker0` bridge, set `DOCKER0_CIDR` to the range required.

See [dvm.conf][dvm_conf] for more details.

## <a name="development"></a> Development

* Source hosted at [GitHub][repo]
* Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## <a name="authors"></a> Authors

Created and maintained by [Fletcher Nichol][fnichol] (<fnichol@nichol.ca>)

## <a name="credits"></a> Credits

* [Steeve Morin (steeve)](https://github.com/steeve) for [boot2docker][boot2docker]
* [Mitchell Hashimoto (mitchellh)](https://github.com/mitchellh) for [Vagrant][vagrant] and [boot2docker Vagrant Box][boot2docker_vagrant_box]
* [Postmodern (postmodern)](https://github.com/postmodern) for awesome examples of killer project skeletons in [chruby](https://github.com/postmodern/chruby) and [ruby-install](https://github.com/postmodern/ruby-install)

## <a name="license"></a> License

Apache 2.0 (see [LICENSE.txt][license])

[license]:      https://github.com/fnichol/dvm/blob/master/LICENSE.txt
[fnichol]:      https://github.com/fnichol
[repo]:         https://github.com/fnichol/dvm
[issues]:       https://github.com/fnichol/dvm/issues

[docker]:         http://www.docker.io/
[docker_api]:     http://docs.docker.io/en/latest/reference/api/docker_remote_api
[docker_dl]:      http://docs.docker.io/en/latest/installation/
[dvm_conf]:       https://github.com/fnichol/dvm/blob/master/dvm.conf
[homebrew_dvm]:   https://github.com/fnichol/homebrew-dvm
[kitchenci]:      http://kitchen.ci
[kitchen_docker]: https://github.com/portertech/kitchen-docker
[parallels_dl]:   http://www.parallels.com/ca/products/desktop/
[vagrant]:        http://www.vagrantup.com/
[vagrant_dl]:     http://www.vagrantup.com/downloads.html
[vmware_fusion_dl]: http://www.vmware.com/go/downloadfusion
[vmware_workstation_dl]: http://www.vmware.com/go/downloadworkstation
[virtualbox_dl]:  https://www.virtualbox.org/wiki/Downloads
[boot2docker]:    https://github.com/steeve/boot2docker
[boot2docker_vagrant_box]: https://github.com/mitchellh/boot2docker-vagrant-box
