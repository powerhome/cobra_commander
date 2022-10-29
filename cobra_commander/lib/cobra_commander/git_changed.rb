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

    InvalidSelectionError = Class.new(StandardError)

    def initialize(repo_root, base_branch)
      @repo_root = repo_root
      @base_branch = base_branch
    end

    def each(&block)
      changes.each(&block)
    end

  private

    def changes
      @changes ||= begin
        diff, _, result = Dir.chdir(@repo_root) do
          Open3.capture3("git", "diff", "--name-only", @base_branch)
        end

        raise InvalidSelectionError, "Specified branch #{@base_branch} could not be found" if result.exitstatus == 128

        diff.split("\n").map do |f|
          File.join(@repo_root, f)
        end
      end
    end
  end
end
