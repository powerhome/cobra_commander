# frozen_string_literal: true

require "cobra_commander/component_tree"

module CobraCommander
  # Formats CLI ls output
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

    def dependents_of!(component_name, format)
      @component_name = component_name

      results = @tree[:dependencies].map do |component|
        if @component_name == component[:name]
          @tree[:name]
        elsif dependency?(component)
          component[:name]
        end
      end.compact

      "list" == format ? results : results.size
    end

  private

    def dependency?(deps)
      deps[:dependencies].each do |dep|
        return true if @component_name == dep[:name] || dependency?(dep)
      end
      false
    end

    def list_dependencies(deps, outdents = [])
      deps[:dependencies].each do |dep|
        decide_on_line(deps, dep, outdents)
      end
    end

    def decide_on_line(parent, dep, outdents)
      if parent[:dependencies].last != dep
        add_tee(outdents, dep)
      else
        add_corner(outdents, dep)
      end
    end

    def add_tee(outdents, dep)
      puts line(outdents, TEE, dep[:name])
      list_dependencies(dep, (outdents + [BAR]))
    end

    def add_corner(outdents, dep)
      puts line(outdents, CORNER, dep[:name])
      list_dependencies(dep, (outdents + [SPACE]))
    end

    def line(outdents, sym, name)
      (outdents + [sym] + [name]).join
    end
  end
end
