require 'singleton'
require 'delegate'

module HtmlConditionalComment
  module Nodes
    module Node
      def accept(visitor)
        visitor.visit(self)
      end
    end

    class NodeItem
      include Node
    end

    class Nodes < Array
      include Node
    end

    class ChildOperator < NodeItem
      attr_accessor :child
    end
    class BranchOperator < NodeItem
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

    class Browser < NodeItem
      attr_accessor :feature, :feature_version
    end

    class True < NodeItem
      include Singleton
    end

    class False < NodeItem
      include Singleton
    end

    class Html < NodeItem
      attr_accessor :string
    end
  end
end
