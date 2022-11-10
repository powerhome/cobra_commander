# frozen_string_literal: true

module AppHelper
  def fixture_path
    Pathname.new(__dir__)
  end

  def fixture_file_path(name)
    Pathname.new(name).expand_path(fixture_path)
  end

  def fixture_file(name)
    fixture_file_path(name).open
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
