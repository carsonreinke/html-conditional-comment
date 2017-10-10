module HtmlConditionalComment
  class ParseError < StandardError; end

  #
  # Pseudo grammar
  #
  #expression = term [ "|" , term ]
  #term = factor [ "&" , factor ]
  #factor = subexpression | "!" , factor | "(" , expression , ")"
  #subexpression = [ operator ] browser | boolean
  #operator = "gt" | "gte" | "lt" | "lte"
  #boolean = "true" | "false"
  #browser = feature [ feature_version ]
  #
  class Parser
    def initialize(tokens)
      @symbol = nil
      @tokens = tokens
      @pos = -1
    end


<<-COMMENT

Item	Example	Comment
!	[if !IE]	The NOT operator. This is placed immediately in front of the feature, operator, or subexpression to reverse the Boolean meaning of the expression.
lt	[if lt IE 5.5]	The less-than operator. Returns true if the first argument is less than the second argument.
lte	[if lte IE 6]	The less-than or equal operator. Returns true if the first argument is less than or equal to the second argument.
gt	[if gt IE 5]	The greater-than operator. Returns true if the first argument is greater than the second argument.
gte	[if gte IE 7]	The greater-than or equal operator. Returns true if the first argument is greater than or equal to the second argument.
( )	[if !(IE 7)]	Subexpression operators. Used in conjunction with boolean operators to create more complex expressions.
&	[if (gt IE 5)&(lt IE 7)]	The AND operator. Returns true if all subexpressions evaluate to true
|	[if (IE 6)|(IE 7)]	The OR operator. Returns true if any of the subexpressions evaluates to true.

<expression>::=<term>{<or><term>}
<term>::=<factor>{<and><factor>}
<factor>::=<constant>|<not><factor>|(<expression>)
<constant>::= false|true
<or>::='|'
<and>::='&'
<not>::='!'

public BooleanExpression build() {
  expression();
  return root;
}
private void expression() {
  term();
  while (symbol == Lexer.OR) {
    Or or = new Or();
    or.setLeft(root);
    term();
    or.setRight(root);
    root = or;
  }
}
private void term() {
  factor();
  while (symbol == Lexer.AND) {
    And and = new And();
    and.setLeft(root);
    factor();
    and.setRight(root);
    root = and;
  }
}
private void factor() {
  symbol = lexer.nextSymbol();
  if (symbol == Lexer.TRUE) {
    root = t;
    symbol = lexer.nextSymbol();
  } else if (symbol == Lexer.FALSE) {
    root = f;
    symbol = lexer.nextSymbol();
  } else if (symbol == Lexer.NOT) {
    Not not = new Not();
    factor();
    not.setChild(root);
    root = not;
  } else if (symbol == Lexer.LEFT) {
    expression();
    symbol = lexer.nextSymbol(); // we don't care about ')'
  } else {
    throw new RuntimeException("Expression Malformed");
  }
}

http://www.craftinginterpreters.com/parsing-expressions.html
https://unnikked.ga/how-to-build-a-boolean-expression-evaluator-518e9e068a65
COMMENT




    def browser()
      node = Nodes::Browser.new()
      node.feature = @value
      expect(:feature)

      if current(:feature_version)
        node.feature_version = @value
        accept(:feature_version)
      end

      node
    end

    def boolean()
      if accept(:boolean_true)
        Nodes::True.instance()
      elsif accept(:boolean_false)
        Nodes::False.instance()
      else
        #TODO
        raise 'Syntax error'
      end
    end

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
        #TODO
        raise 'Syntax error'
      end
    end

    def subexpression()
      node = nil

      if current(:operator_less_than) || current(:operator_less_than_equal) ||
        current(:operator_greater_than) || current(:operator_greater_than_equal)

        node = operator()
        node.child = browser()
      elsif current(:boolean_true) || current(:boolean_false)
        node = boolean()
      else
        node = Nodes::Equal.new()
        node.child = browser()
      end

      node
    end

    def factor()
      node = nil

      if accept(:operator_not)
        node = factor()
      elsif accept(:paren_open)
        node = expression()
        expect(:paren_close)
      else
        node = subexpression()
      end

      node
    end

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

    def statement()
      node = Nodes::Condition.new()

      expect(:open)
      expect(:if)
      node.left = expression()
      expect(:close)

      if current(:html)
        node.right = html()
      end

      expect(:open)
      expect(:endif)
      expect(:close)

      node
    end

    def html()
      node = Nodes::Html.new()
      node.string = @value
      expect(:html)
      node
    end

    def template()
      nodes = Nodes::Nodes.new()

      while !@symbol.nil?()
        nodes << if current(:html)
          html()
        elsif current(:open)
          statement()
        else
          raise 'Syntax error' #TODO
        end
      end

      nodes
    end

    def parse()
      self.next()

      #TODO Create AST tree based on parsing using recursive descent
      #https://ruslanspivak.com/lsbasi-part7/
      template()
    end


protected
    def accept(symbol)
      if(symbol == @symbol)
        self.next()
        return true
      else
        return false
      end
    end

    def expect(symbol)
      #TODO
      raise "Unexpected symbol: #{@value}" unless accept(symbol)
    end

    def current(symbol)
      @symbol == symbol
    end

    def next()
      @pos += 1
      #TODO Out of bounds
      token = @tokens[@pos] || []
      @symbol = token[0]
      @value = token[1]
      token
    end
  end
end
