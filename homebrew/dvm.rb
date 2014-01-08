require 'formula'

class Dvm < Formula
  homepage 'http://fnichol.github.io/dvm'
  url 'https://github.com/fnichol/dvm/archive/v0.2.2.tar.gz'
  sha1 'e9e2b164fb3f2b352e8dc71cf39386110c9575f1'

  head 'https://github.com/fnichol/dvm.git'

  def install
    system 'make', 'install', "PREFIX=#{prefix}"
  end

  def caveats; <<-EOS.undent
    Quickstart:

        dvm up
        eval $(dvm env)
        docker images

    If you will only be using Docker with dvm, consider adding the following
    to your ~/.bash_profile or ~/.bashrc to always have DOCKER_HOST properly
    set:

        eval "$(dvm env)"

    EOS
  end
end
