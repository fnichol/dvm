require 'formula'

class Dvm < Formula
  homepage 'http://fnichol.github.io/dvm'
  url 'https://github.com/fnichol/dvm/archive/v0.2.0.tar.gz'
  sha1 '509203b626f4b999418c15391f38c658a16d982c'

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
