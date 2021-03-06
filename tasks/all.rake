# Miscellaneous build tasks

require 'tmpdir'
require 'tempfile'
require 'fileutils'

namespace :build do
  desc 'Confirm the correct Ruby environment for development and deployment'
  task :confirm_ruby => :os_dependencies do
    expectation = "#{RUBY_BUILD}/bin"
    %w[ ruby gem rake ].each do |cmd|
      raise "#{cmd} not running from #{expectation}. Did you source env.sh?" unless `which #{cmd}`.chomp.match(Regexp.new("#{expectation}/#{cmd}$"))
    end
  end

  desc 'Hook into the Ruby in a Box environment to get everything else built and installed'
  task :ruby_inabox => :couchdb

  desc 'Confirm (and install if possible) the OS dependencies'
  task :os_dependencies => [:mac_dependencies, :ubuntu_dependencies, :debian_dependencies, :opensuse_dependencies]

  task :debian_dependencies => :known_distro do
    if DISTRO[0] == :debian
      install [
        # For building OTP
        %w[ flex dctrl-tools libsctp-dev ],

        # All Ubuntu gets these.
        %w[ libxslt1-dev automake libcurl4-openssl-dev make ruby libtool g++ ],
        %w[ zip libcap2-bin ],

        # Needed for Varnish
        # %w[ libpcre3-dev ]
      ].flatten
    end
  end

  task :ubuntu_dependencies => :known_distro do
    if DISTRO[0] == :ubuntu
      # For building OTP
      install %w[ flex dctrl-tools libsctp-dev ]

      # All Ubuntu gets these.
      install %w[ libxslt1-dev automake libcurl4-openssl-dev make ruby libtool g++ ]
      install %w[ zip libcap2-bin ]

      # Needed for Varnish
      #install %w[ libpcre3-dev ]
    end
  end

  task :mac_dependencies => :known_distro do
    %w[ gcc make ].each do |dep|
      raise 'Please install Xcode from Apple' if DISTRO[0] == :osx and system("#{dep} --version > /dev/null 2> /dev/null") == false
    end
  end

  task :opensuse_dependencies => :known_distro do
    if DISTRO[0] == :opensuse
      # For building OTP
      install %w[ flex lksctp-tools-devel zip]

      # All OpenSUSE gets these.
      install %w[rubygem-rake gcc-c++ make m4 zlib-devel libopenssl-devel libtool automake libcurl-devel]

    end
  end


  desc 'Clean all CouchDB-related build output'
  task :clean do
    sh "rm -rf #{BUILD}"
  end

end
