module HtmlConditionalComment
  class Visitor
    #Copied from https://blog.bigbinary.com/2013/07/07/visitor-pattern-and-double-dispatch.html
    def visit(subject)
      method_name = "visit_#{subject.class}".intern()
      self.send(method_name, subject)
    end
  end
end
