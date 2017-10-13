require 'html-conditional-comment/version'
require 'html-conditional-comment/lexer'
require 'html-conditional-comment/parser'
require 'html-conditional-comment/nodes'
require 'html-conditional-comment/visitor'
require 'html-conditional-comment/version_vector'

module HtmlConditionalComment
  class << self
    ##
    # Tokenize the HTML into an array of tokens 
    #
    def lex(html)
      Lexer.new(html).tokenize()
    end

    ##
    # Parse into tree of nodes the HTML
    #
    def parse(html)
      Parser.new(self.lex(html)).parse()
    end

    ##
    # Evaluate conditional comments in HTML using the supplied browser
    # information and return a string
    #
    # * +features+ - String or Array of features of browser
    # * +version+ - String, Integer, or Float representing version of the browser
    #
    def to_string(html, features, version)
      self.parse(html).accept(Visitors::ToString.new(features, version))
    end
  end
end
