require 'singleton'

module HtmlConditionalComment
  module Nodes
    class Node
      def accept(visitor)
        visitor.visit(self)
      end
    end

    class Nodes < Array
      def accept(visitor)
        self.each do |node|
          visitor.visit(node)
        end
      end
    end

    class ChildOperator < Node
      attr_accessor :child
    end
    class BranchOperator < Node
      attr_accessor :left, :right
    end
    class Comparison < ChildOperator; end

    class Condition < BranchOperator; end

    class Or < BranchOperator; end
    class And < BranchOperator; end
    class Not < ChildOperator; end

    class Equal < Comparison; end
    class LessThan < Comparison; end
    class LessThanEqual < Comparison; end
    class GreaterThan < Comparison; end
    class GreaterThanEqual < Comparison; end

    class Browser < Node
      attr_accessor :feature, :feature_version
    end

    class True < Node
      include Singleton
    end

    class False < Node
      include Singleton
    end

    class Html < Node
      attr_accessor :string
    end
  end
end
