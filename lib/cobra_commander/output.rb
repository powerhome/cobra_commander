# frozen_string_literal: true

module CobraCommander
  # Module for pretty printing dependency trees
  module Output
    def self.print(node, format)
      output = format == "list" ? Output::FlatList.new(node) : Output::Tree.new(node)
      puts output.to_s
    end

    # Flattens a tree and prints unique items
    class FlatList
      def initialize(tree)
        @tree = tree
      end

      def to_s
        @tree.deep_dependencies.map(&:name).sort
      end
    end

    # Prints the tree in a nice tree form
    class Tree
      attr_accessor :tree

      SPACE  = "    "
      BAR    = "│   "
      TEE    = "├── "
      CORNER = "└── "

      def initialize(node)
        @node = node
      end

      def to_s
        StringIO.new.tap do |io|
          io.puts @node.name
          list_dependencies(io, @node)
        end.string
      end

    private

      def list_dependencies(io, node, outdents = [])
        node.dependencies.each do |dep|
          decide_on_line(io, node, dep, outdents)
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
