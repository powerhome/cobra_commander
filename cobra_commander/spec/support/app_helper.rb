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
    CobraCommander::Umbrella.new(path, stub: true)
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
end
