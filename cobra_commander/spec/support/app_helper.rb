# frozen_string_literal: true

require "yaml"

module AppHelper
  def stub_umbrella(name = nil, unpack: false)
    path = if unpack
             unpacked_path = Pathname.new(Dir.mktmpdir).realpath
             package = fixture_file_path("#{name}.tgz")
             system(`tar xfz #{package} -C #{unpacked_path}`)
             unpacked_path.join(name)
           else
             fixture_file_path(name)
           end
    CobraCommander.umbrella(path, stub: true)
  end

  def fixture_path
    Pathname.new(__dir__).join("..", "fixtures")
  end

  def fixture_file_path(name)
    Pathname.new(name).expand_path(fixture_path)
  end

  def fixture_file(name)
    fixture_file_path(name).open
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
