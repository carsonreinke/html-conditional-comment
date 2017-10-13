module HtmlConditionalComment
  class VisitError < StandardError
    def initialize(klass)
      super("Cannot visit #{klass}")
    end
  end

  module Visitors
    class Visitor
      def initialize(features, version)
        @features = features
        @features = [@features] unless @features.is_a?(Enumerable)

        @version = if version.is_a?(VersionVector)
          version
        else
          VersionVector.new(version)
        end
      end

      #Copied from https://blog.bigbinary.com/2013/07/07/visitor-pattern-and-double-dispatch.html
      def visit(subject)
        method_name = :"visit_#{(subject.class.name || '').gsub('::', '_')}"
        __send__(method_name, subject)
      end

      #Provide method missing for better interpretation
      def method_missing(method, args)
        if method.to_s() =~ /^visit\_(.+)/
          raise VisitError.new($1)
        else
          super(method, args)
        end
      end
    end

    ##
    # Evaluates conditions to boolean
    #
    class Eval < Visitor
    protected
      def visit_HtmlConditionalComment_Nodes_True(subject)
        true
      end
      def visit_HtmlConditionalComment_Nodes_False(subject)
        false
      end
      def visit_HtmlConditionalComment_Nodes_Browser(subject)
        @features.include?(subject.feature)
      end

      def visit_HtmlConditionalComment_Nodes_Equal(subject)
        subject.child.accept(self) && @version == subject.child.version_vector
      end
      def visit_HtmlConditionalComment_Nodes_LessThan(subject)
        subject.child.accept(self) && @version < subject.child.version_vector
      end
      def visit_HtmlConditionalComment_Nodes_LessThanEqual(subject)
        subject.child.accept(self) && @version <= subject.child.version_vector
      end
      def visit_HtmlConditionalComment_Nodes_GreaterThan(subject)
        subject.child.accept(self) && @version > subject.child.version_vector
      end
      def visit_HtmlConditionalComment_Nodes_GreaterThanEqual(subject)
        subject.child.accept(self) && @version >= subject.child.version_vector
      end

      def visit_HtmlConditionalComment_Nodes_Or(subject)
        subject.left.accept(self) || subject.right.accept(self)
      end
      def visit_HtmlConditionalComment_Nodes_And(subject)
        subject.left.accept(self) && subject.right.accept(self)
      end
      def visit_HtmlConditionalComment_Nodes_Not(subject)
        !subject.child.accept(self)
      end
    end

    ##
    # Converts parser nodes to a string by evaluating each conditional comment
    #
    class ToString < Visitor
    protected
      def visit_HtmlConditionalComment_Nodes_Nodes(subject)
        subject.map{|node| node.accept(self)}.join
      end

      def visit_HtmlConditionalComment_Nodes_Condition(subject)
        if subject.left.accept(Eval.new(@features, @version))
          subject.right.accept(self)
        end
      end

      def visit_HtmlConditionalComment_Nodes_Html(subject)
        subject.content
      end
    end
  end
end
