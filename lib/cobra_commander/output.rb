# frozen_string_literal: true

module CobraCommander
  module Output
    def self.print(tree, format)
      output = format == "list" ? Output::FlatList.new(tree) : Output::Tree.new(tree)
      puts output.to_s
    end

    class FlatList
      def initialize(tree)
        @tree = tree
      end

      def to_s
        flatten_tree(@tree)
      end

    private

      def flatten_tree(component)
        component.dependencies.map do |dep|
          [dep.name] + flatten_tree(dep)
        end.flatten.uniq
      end
    end

    class Tree
      attr_accessor :tree

      SPACE  = "    "
      BAR    = "│   "
      TEE    = "├── "
      CORNER = "└── "

      def initialize(tree)
        @tree = tree
      end

      def to_s
        StringIO.new.tap do |io|
          io.puts @tree.name
          list_dependencies(io, @tree)
        end.string
      end

    private

      def list_dependencies(io, deps, outdents = [])
        deps.dependencies.each do |dep|
          decide_on_line(io, deps, dep, outdents)
        end
        nil
      end

      def decide_on_line(io, parent, dep, outdents)
        if parent.dependencies.last != dep
          add_tee(io, outdents, dep)
        else
          add_corner(io, outdents, dep)
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
