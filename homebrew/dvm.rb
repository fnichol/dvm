require 'formula'

class Dvm < Formula
  homepage 'https://github.com/fnichol/dvm#readme'
  url 'https://github.com/fnichol/dvm/archive/v0.0.1.tar.gz'
  sha1 '320d13bacafeae72631093dba1cd5526147d03cc'

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
