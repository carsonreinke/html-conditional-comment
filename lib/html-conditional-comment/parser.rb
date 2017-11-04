module HtmlConditionalComment
  class ParseError < StandardError
    def initialize(msg, example)
      super("#{msg} at \"#{example.to_s.slice(0, 25)}\"")
    end
  end

  ##
  #
  # Parse tokens into a tree of nodes
  #
  # Pseudo grammar
  #
  #template = { html | statement }
  #statement = "<!" , [ "--" ] , "if" , expression , "]" , [ "--" ] , ">" , template , "<!" , [ "--" ] , "endif" , "]" , [ "--" ] , ">"
  #expression = term [ "|" , term ]
  #term = factor [ "&" , factor ]
  #factor = subexpression | "!" , factor | "(" , expression , ")"
  #subexpression = [ operator ] browser | boolean
  #operator = "gt" | "gte" | "lt" | "lte"
  #boolean = "true" | "false"
  #browser = feature [ version_vector ]
  #
  class Parser
    OPEN = /\-\->$/
    CLOSE = /<!\-\-$/

    def initialize(tokens)
      @symbol = nil
      @tokens = tokens
      @max_pos = tokens.size() - 1
      @pos = -1
    end

    def parse()
      self.next()

      nodes = template()

      #Tokens left, syntax error
      error() if @pos < @max_pos

      nodes
    end


protected
    #Browser is combination of feature and optional version
    def browser()
      node = Nodes::Browser.new()
      node.feature = @value
      expect(:feature)

      if current(:version_vector)
        node.version_vector = VersionVector.new(@value)
        accept(:version_vector)
      else
        node.version_vector = VersionVector.new(nil)
      end

      node
    end

    #True or false
    def boolean()
      if accept(:boolean_true)
        Nodes::True.instance()
      elsif accept(:boolean_false)
        Nodes::False.instance()
      else
        error()
      end
    end

    #Comparison operators
    def operator()
      if accept(:operator_less_than)
        Nodes::LessThan.new()
      elsif accept(:operator_less_than_equal)
        Nodes::LessThanEqual.new()
      elsif accept(:operator_greater_than)
        Nodes::GreaterThan.new()
      elsif accept(:operator_greater_than_equal)
        Nodes::GreaterThanEqual.new()
      else
        error()
      end
    end

    #Either a comparison with the browser, boolean, or simply just the browser
    def subexpression()
      node = nil

      if current(:operator_less_than) || current(:operator_less_than_equal) ||
        current(:operator_greater_than) || current(:operator_greater_than_equal)

        node = operator()
        node.child = browser()
      elsif current(:boolean_true) || current(:boolean_false)
        node = boolean()
      else
        #No comparison operator is assuming equals
        node = Nodes::Equal.new()
        node.child = browser()
      end

      node
    end

    #Negated self or paranthesised expression
    def factor()
      node = nil

      if accept(:operator_not)
        node = Nodes::Not.new()
        node.child = factor()
      elsif accept(:paren_open)
        node = expression()
        expect(:paren_close)
      else
        node = subexpression()
      end

      node
    end

    #And
    def term()
      node = factor()
      while accept(:operator_and)
        branch_node = Nodes::And.new()
        branch_node.left = node
        branch_node.right = factor()
        node = branch_node
      end

      node
    end

    #Or
    def expression()
      node = term()
      while accept(:operator_or)
        branch_node = Nodes::Or.new()
        branch_node.left = node
        branch_node.right = term()
        node = branch_node
      end

      node
    end

    def condition()
      node = Nodes::Condition.new()

      expect(:open)
      expect(:if)
      node.left = expression()

      #TODO Goofy confirmation of non-closing HTML comment
      if current(:close)
        error() if @value =~ OPEN
      end
      expect(:close)

      unless current(:open) && peek(:endif)
        node.right = template()
      end

      #TODO More goofyness
      if current(:open)
        error() if @value =~ CLOSE
      end
      expect(:open)

      expect(:endif)
      expect(:close)

      node
    end

    def html()
      node = Nodes::Html.new()
      node.content = @value
      expect(:html)
      node
    end

    def template()
      nodes = Nodes::Nodes.new()

      while current(:html) || (current(:open) && peek(:if))
        nodes << if current(:html)
          html()
        elsif current(:open) && peek(:if)
          condition()
        end
      end

      nodes
    end


protected
    #Accept the symbol and move on or not
    def accept(symbol)
      if(symbol == @symbol)
        self.next()
        return true
      else
        return false
      end
    end

    #Expect a current symbol or raise
    def expect(symbol)
      raise HtmlConditionalComment::ParseError.new("Expected #{symbol}, received #{@symbol}", @value) unless accept(symbol)
    end

    def current(symbol)
      @symbol == symbol
    end

    def peek(symbol)
      @tokens[@pos+1][0] == symbol
    end

    def next()
      @pos += 1
      #raise HtmlConditionalComment::ParserError.new('EOF') if @pos >= @max_pos
      token = @tokens[@pos] || []
      @symbol = token[0]
      @value = token[1]
      token
    end

    def error()
      raise HtmlConditionalComment::ParseError.new("Syntax error", @value)
    end
  end
end
