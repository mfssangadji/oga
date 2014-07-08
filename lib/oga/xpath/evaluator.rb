module Oga
  module XPath
    ##
    # The Evaluator class is used to evaluate an XPath expression in the
    # context of a given document.
    #
    class Evaluator
      ##
      # @param [Oga::XML::Document|Oga::XML::Node] document
      #
      def initialize(document)
        @document = document

        reset
      end

      def reset
        @context = @document.children
        @stack   = XML::NodeSet.new
      end

      def evaluate(string)
        ast = Parser.new(string).parse

        process(ast)

        nodes = @stack

        reset

        return nodes
      end

      def process(node)
        handler = "on_#{node.type}"

        if respond_to?(handler)
          send(handler, node)
        end
      end

      def on_path(node)
        test, children = *node

        process(test)

        if children and !@stack.empty?
          swap_context

          process(children)
        end
      end

      def on_test(node)
        ns, name = *node

        @context.each do |xml_node|
          next unless xml_node.is_a?(XML::Element)

          if xml_node.name == name and xml_node.namespace == ns
            @stack << xml_node
          end
        end
      end

      def swap_context
        @context = XML::NodeSet.new

        @stack.each do |xml_node|
          xml_node.children.each do |child|
            @context << child
          end
        end

        @stack = XML::NodeSet.new
      end
    end # Evaluator
  end # XPath
end # Oga
