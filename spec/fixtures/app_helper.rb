# frozen_string_literal: true

module AppHelper
  def fixture_app
    @fixture_app
  end

  def fixture_umbrella
    @fixture_umbrella ||= CobraCommander.umbrella(fixture_app)
  end

  def self.configure(config, tgz_file)
    config.include AppHelper

    config.before :each do
      @fixture_app = Pathname.new(Dir.mktmpdir).realpath
      system(`tar xfz #{tgz_file} -C #{fixture_app}`)
    end

    config.after :each do
      FileUtils.rm_r fixture_app
    end
  end
end
