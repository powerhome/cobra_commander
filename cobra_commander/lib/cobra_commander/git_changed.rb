# frozen_string_literal: true

require "open3"

module CobraCommander
  # List of files changed in a git repository in the current branch in relation
  # to the give base branch
  #
  # @private
  #
  class GitChanged
    include Enumerable

    Error = Class.new(StandardError)
    InvalidSelectionError = Class.new(Error)

    def initialize(path, base_branch)
      @path = path
      @base_branch = base_branch
    end

    def each(&block)
      changes.each(&block)
    end

  private

    def changes
      @changes ||= Dir.chdir(@path) do
        git_dir, _, result = Open3.capture3("git", "rev-parse", "--git-dir")
        validate_result!(result)

        diff, _, result = Open3.capture3("git", "diff", "--name-only", @base_branch)
        validate_result!(result)

        git_dir = Pathname.new(git_dir)
        diff.split("\n").map { |f| git_dir.dirname.join(f) }
      end
    end

    def validate_result!(result)
      raise InvalidSelectionError, "Specified branch #{@base_branch} could not be found" if result.exitstatus == 128
      raise Error, "Uknown git error: #{result.inspect}" if result.exitstatus > 0
    end
  end
end
