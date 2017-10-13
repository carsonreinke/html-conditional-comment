require 'html-conditional-comment/version'
require 'html-conditional-comment/lexer'
require 'html-conditional-comment/parser'
require 'html-conditional-comment/nodes'
require 'html-conditional-comment/visitor'
require 'html-conditional-comment/version_vector'

module HtmlConditionalComment
  class << self
    ##
    #
    #
    def lex(html)
      Lexer.new(html).tokenize()
    end

    ##
    #
    #
    def parse(html)
      Parser.new(self.lex(html)).parse()
    end

    ##
    #
    #
    def to_string(html, features, version)
      self.parse(html).accept(Visitors::ToString.new(features, version))
    end
  end
end
