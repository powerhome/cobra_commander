# frozen_string_literal: true

require "cbra/component_tree"

module Cbra
  # Formats CLI output
  class FormattedOutput
    attr_accessor :tree

    SPACE  = "    "
    BAR    = "│   "
    TEE    = "├── "
    CORNER = "└── "

    def initialize(app_path)
      @tree = ComponentTree.new(app_path).to_h
    end

    def run!
      puts @tree[:name]
      list_dependencies(@tree)
      nil
    end

  private

    def list_dependencies(deps, outdents = [])
      deps[:dependencies].each do |dep|
        if deps[:dependencies].last != dep
          puts line(outdents, TEE, dep[:name])
          list_dependencies(dep, ([BAR] + outdents))
        else
          puts line(outdents, CORNER, dep[:name])
          list_dependencies(dep, (outdents + [SPACE]))
        end
      end
    end

    def line(outdents, sym, name)
      (outdents + [sym] + [name]).join
    end
  end
end
