# frozen_string_literal: true

require "stringio"

module CobraCommander
  module CLI::Output
    # Prints the tree in a nice tree form
    class AsciiTree
      SPACE = "    "
      BAR = "│   "
      TEE = "├── "
      CORNER = "└── "

      def initialize(components)
        @components = components
      end

      def to_s
        StringIO.new.tap do |io|
          @components.each do |component|
            io.puts component.name
            list_dependencies(io, component)
          end
        end.string
      end

    private

      def list_dependencies(io, component, outdents = [])
        component.dependencies.each do |dep|
          decide_on_line(io, component, dep, outdents)
        end
        nil
      end

      def decide_on_line(io, parent, dep, outdents)
        if parent.dependencies.last == dep
          add_corner(io, outdents, dep)
        else
          add_tee(io, outdents, dep)
        end
      end

      def add_tee(io, outdents, dep)
        io.puts line(outdents, TEE, dep.name)
        list_dependencies(io, dep, (outdents + [BAR]))
      end

      def add_corner(io, outdents, dep)
        io.puts line(outdents, CORNER, dep.name)
        list_dependencies(io, dep, (outdents + [SPACE]))
      end

      def line(outdents, sym, name)
        (outdents + [sym] + [name]).join
      end
    end
  end
end
