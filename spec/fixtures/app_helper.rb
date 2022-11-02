# frozen_string_literal: true

module AppHelper
  def fixture_file_path(name)
    File.expand_path(name, __dir__)
  end

  def fixture_file(name)
    File.open(fixture_file_path(name))
  end

  def fixture_umbrella(name)
    unpacked_path = File.join(@tempdir, name)
    unless File.exist?(unpacked_path)
      Dir.mkdir(unpacked_path)
      package = "#{File.expand_path(name, __dir__)}.tgz"
      system(`tar xfz #{package} -C #{unpacked_path}`)
    end
    CobraCommander.umbrella(unpacked_path)
  end

  def self.included(config)
    config.before :each do
      @tempdir = Pathname.new(Dir.mktmpdir).realpath
    end

    config.after :each do
      FileUtils.rm_r @tempdir
    end
  end
end
