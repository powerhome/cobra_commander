# frozen_string_literal: true

require "cbra/component_tree"

module Cbra
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
      @tree[:dependencies].each do |dep|
        if @tree[:dependencies].last != dep
          puts TEE + dep[:name]
        else
          puts CORNER + dep[:name]
        end
        dep[:dependencies].each do |tep|
          if dep[:dependencies].last != tep
            puts BAR + TEE + tep[:name]
          else
            puts BAR + CORNER + tep[:name]
          end
        end
      end
      return
    end
  end
end
