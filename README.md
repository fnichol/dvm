# dvm

An on demand [Docker][docker] virtual machine, thanks to [Vagrant][vagrant] and [boot2docker][boot2docker]. Works great on Macs and other platforms that don't natively support the Docker daemon. Under the covers this is downloading and booting Mitchell Hashimoto's [boot2docker Vagrant Box][boot2docker_vagrant_box] image.

## <a name="install"></a> Install

```sh
wget -O dvm-0.1.0.tar.gz https://github.com/fnichol/dvm/archive/v0.1.0.tar.gz
tar -xzvf dvm-0.1.0.tar.gz
cd dvm-0.1.0/
sudo make install
```

### <a name="intsall-homebrew"></a> Homebrew (Mac)

```sh
brew install https://raw.github.com/sevki/homebrew-binary/master/docker.rb
brew install https://raw.github.com/fnichol/dvm/master/homebrew/dvm.rb
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

[docker]:       http://www.docker.io/
[vagrant]:      http://www.vagrantup.com/
[boot2docker]:  https://github.com/steeve/boot2docker
[boot2docker_vagrant_box]: https://github.com/mitchellh/boot2docker-vagrant-box
