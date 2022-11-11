# frozen_string_literal: true

require "yaml"

module AppHelper
  class StubSource < CobraCommander::Source[:stub]
    def packages
      @packages ||= YAML.load_file("#{path}.yml").map do |name, dependencies|
        CobraCommander::Package.new(self, name: name,
                                          path: path.join(name),
                                          dependencies: dependencies || [])
      end
    end
  end

  def stub_umbrella(path = nil)
    CobraCommander.umbrella(fixture_file_path(path), stub: true)
  end

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
    CobraCommander.umbrella(unpacked_path, ruby: true, js: true)
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
