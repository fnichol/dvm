# dvm

An on demand [Docker][docker] virtual machine, thanks to [Vagrant][vagrant] and [boot2docker][boot2docker]. Works great on Macs and other platforms that don't natively support the Docker daemon. Under the covers this is downloading and booting Mitchell Hashimoto's [boot2docker Vagrant Box][boot2docker_vagrant_box] image.

## <a name="mac-tl-dr"></a> tl;dr for Mac Users

Are you already a Vagrant user using Virtualbox? Use Homebrew? Great!


```sh
# Install Docker Mac binary (see note below)
brew install https://raw.github.com/sevki/homebrew-binary/master/docker.rb

# Install dvm
brew install https://raw.github.com/fnichol/dvm/master/homebrew/dvm.rb

# Bring up your Vagrant/Docker VM
dvm up

# Set a DOCKER_HOST environment variable that points to your VM
eval $(dvm env)

# Run plain 'ol Docker commands right from your Mac
docker run ubuntu cat /etc/lsb-release
```

**Note**: The Homebrew/Docker install URL is temporary, pending the merging of https://github.com/Homebrew/homebrew-binary/pull/45 into [homebrew-binary](https://github.com/Homebrew/homebrew-binary).

p.s. No Vagrant or VirtualBox installed? Check out the [Requirements](#requirements) section below.

## <a name="requirements"></a> Requirements

* [VirtualBox][virtualbox_dl], version 4.3.4+
* [Vagrant][vagrant_dl], version 1.4.0+
* (*Optional*) [Docker][docker_dl], version 0.7.3+ or use the [Docker Remote API][docker_api]

## <a name="install"></a> Install

Installation is supported for any Unixlike platform that Vagrant and VirtualBox support.

```sh
wget -O dvm-0.2.0.tar.gz https://github.com/fnichol/dvm/archive/v0.2.0.tar.gz
tar -xzvf dvm-0.2.0.tar.gz
cd dvm-0.2.0/
sudo make install
```

### <a name="intsall-homebrew"></a> Homebrew (Mac)

There is a vendored Homebrew formula which can be installed with:

```sh
brew install https://raw.github.com/fnichol/dvm/master/homebrew/dvm.rb
```

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
  reload          Restarts vagrant machine, loads new configuration
  resume          Resume the suspended vagrant machine
  ssh             Connects to the machine via SSH
  status          Outputs status of the vagrant machine
  suspend, pause  Suspends the machine
  up, start       Starts and provisions the vagrant environment
  vagrant         Issue subcommands directly to the vagrant CLI
```

Keep in mind that dvm thiny wraps Vagrant so don't hesitate to use raw Vagrant commands in your `$HOME/.dvm` directory. Or use the `dvm vagrant` subcommand from anywhere:

```
$ dvm vagrant --version
Vagrant 1.4.2
```

Bring up your VM with `dvm up`:

```
$ dvm up
Bringing machine 'dvm' up with 'virtualbox' provider...
...<snip>...
[dvm] Configuring and enabling network interfaces...
[dvm] Running provisioner: shell...
[dvm] Running: inline script
---> Configuring docker to bind to tcp/4243 and restarting
```

Need to free up some memory? Pause your VM with `dvm suspend`:

```
$ dvm suspend
[dvm] Saving VM state and suspending execution...
```

When you come back to your Dockerawesome project resume your VM with `dvm resume`:

```
$ dvm resume
[dvm] Resuming suspended VM...
[dvm] Booting VM...
[dvm] Waiting for machine to boot. This may take a few minutes...
[dvm] Machine booted and ready!
```

Your local `docker` binary needs to be told that it is targetting a remote system and to not try the local Unix socket, which is the default behavior. Version 0.7.3 of Docker introduced the `DOCKER_HOST` environment variable that will set the target Docker host. By default, dvm will run your VM on a private network at **192.168.42.43** with Docker listening on port **4243**. The `dvm env` subcommand will print a suitable `DOCKER_HOST` line that can be used in your environment. If you want this loaded into your session, evaluate the resulting config with:

```
$ echo $DOCKER_HOST

$ eval `dvm env`

$ echo $DOCKER_HOST
tcp://192.168.42.43:4243
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
docker@boot2docker:~$ uname -a
Linux boot2docker 3.12.1-tinycore64 #1 SMP Sun Dec 8 19:38:19 UTC 2013 x86_64 GNU/Linux
docker@boot2docker:~$
```

## <a name="usage-embedded"></a> Embed in a Project

As the core of dvm is a Vagranfile (surprise!) you can simply download the dvm Vagrantfile into your project using the http://git.io/dvm-vagrantfile shortlink:

```sh
wget -O Vagrantfile http://git.io/dvm-vagrantfile
```

## <a name="configuration"></a> Configuration

If you wish to change the Docker TCP port or memory settings of the virtual machine, edit `$HOME/.dvm/dvm.conf` for the configuration to be used. By default the following configuration is used:

* `DOCKER_IP`: `192.168.42.43`
* `DOCKER_PORT`: `4243`
* `DOCKER_MEMORY`: `512` (in MB)
* `DOCKER_ARGS`: `-H unix:///var/run/docker.sock -H tcp://0.0.0.0:$DOCKER_PORT`

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

## <a name="license"></a> License

Apache 2.0 (see [LICENSE.txt][license])

[license]:      https://github.com/fnichol/dvm/blob/master/LICENSE.txt
[fnichol]:      https://github.com/fnichol
[repo]:         https://github.com/fnichol/dvm
[issues]:       https://github.com/fnichol/dvm/issues

[docker]:         http://www.docker.io/
[docker_api]:     http://docs.docker.io/en/latest/api/docker_remote_api/
[docker_dl]:      http://docs.docker.io/en/latest/installation/
[vagrant]:        http://www.vagrantup.com/
[vagrant_dl]:     http://www.vagrantup.com/downloads.html
[virtualbox_dl]:  https://www.virtualbox.org/wiki/Downloads
[boot2docker]:    https://github.com/steeve/boot2docker
[boot2docker_vagrant_box]: https://github.com/mitchellh/boot2docker-vagrant-box
