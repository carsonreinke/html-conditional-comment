module HtmlConditionalComment
  class VisitError < StandardError
    def initialize(klass)
      super("Cannot visit #{klass}")
    end
  end

  class Visitor
    def initialize(features, version)
      @features = features
      @features = [@features] unless @features.is_a?(Enumerable)

      @version = version.to_f()
    end

    #Copied from https://blog.bigbinary.com/2013/07/07/visitor-pattern-and-double-dispatch.html
    def visit(subject)
      method_name = "visit_#{(subject.class.name || '').gsub('::', '_')}".to_sym()
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

  class EvalVisitor < Visitor
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
      subject.child.accept(self) && subject.child.feature_version.nil?() ? true : @version == subject.child.feature_version
    end
    def visit_HtmlConditionalComment_Nodes_LessThan(subject)
      subject.child.accept(self) && subject.child.feature_version.nil?() ? true : @version < subject.child.feature_version
    end
    def visit_HtmlConditionalComment_Nodes_LessThanEqual(subject)
      subject.child.accept(self) && subject.child.feature_version.nil?() ? true : @version <= subject.child.feature_version
    end
    def visit_HtmlConditionalComment_Nodes_GreaterThan(subject)
      subject.child.accept(self) && subject.child.feature_version.nil?() ? true : @version > subject.child.feature_version
    end
    def visit_HtmlConditionalComment_Nodes_GreaterThanEqual(subject)
      subject.child.accept(self) && subject.child.feature_version.nil?() ? true : @version >= subject.child.feature_version
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

  class ToStringVisitor < Visitor
    def initialize(*args)
      super(*args)
    end

    def visit_HtmlConditionalComment_Nodes_Nodes(subject)
      subject.map{|node| node.accept(self)}.join
    end

    def visit_HtmlConditionalComment_Nodes_Condition(subject)
      if subject.left.accept(EvalVisitor.new(@features, @version))
        subject.right.accept(self)
      end
    end

    def visit_HtmlConditionalComment_Nodes_Html(subject)
      subject.string
    end
  end
end
