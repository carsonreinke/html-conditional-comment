require 'test_helper'

class HtmlConditionalComment::LexerTest < Minitest::Test
  def test_tokenize_downlevel_hidden
    tokens =
      HtmlConditionalComment::Lexer.new('<!--[if true]> HTML <![endif]-->').
      tokenize()
    assert_equal [[:open, "<!--["], [:if, "if"], [:boolean_true, "true"], [:close, "]>"], [:html, " HTML "], [:open, "<!["], [:endif, "endif"], [:close, "]-->"]],
      tokens
  end

  def test_tokenize_downlevel_revealed
    tokens =
      HtmlConditionalComment::Lexer.new('<![if true]> HTML <![endif]>').
      tokenize()
    assert_equal [[:open, "<!["], [:if, "if"], [:boolean_true, "true"], [:close, "]>"], [:html, " HTML "], [:open, "<!["], [:endif, "endif"], [:close, "]>"]],
      tokens
  end

  def test_tokenize_additional_html
    tokens =
      HtmlConditionalComment::Lexer.new('HTML<!--[if true]><p>HTML</p><![endif]-->HTML').
      tokenize()
    assert_equal [:html, 'HTML'], tokens[0]
    assert_equal [:html, 'HTML'], tokens[-1]
  end

  def test_tokenize_additional_comments
    tokens =
      HtmlConditionalComment::Lexer.new('<!--Before--><!--[if true]><![endif]--><!--After-->').
      tokenize()
    assert_equal '<!--Before-->', tokens[0][1]
    assert_equal '<!--After-->', tokens[-1][1]
  end

  def test_tokenize_feature
    tokens =
      HtmlConditionalComment::Lexer.new('<!--[if IE 6]><![endif]-->').
      tokenize()
    assert_equal [:feature, 'IE'], tokens[2]
    assert_equal [:feature_version, '6'], tokens[3]
  end

  def test_tokenize_complex
    tokens =
      HtmlConditionalComment::Lexer.new('<!--[if (gte IE 5.5)|(gt IE 6)&!(lt IE 7)]><![endif]-->').
      tokenize()
    assert_equal [[:open, "<!--["], [:if, "if"], [:paren_open, "("], [:operator_greater_than_equal, "gte"], [:feature, "IE"], [:feature_version, "5.5"], [:paren_close, ")"], [:operator_or, "|"], [:paren_open, "("], [:operator_greater_than, "gt"], [:feature, "IE"], [:feature_version, "6"], [:paren_close, ")"], [:operator_and, "&"], [:operator_not, "!"], [:paren_open, "("], [:operator_less_than, "lt"], [:feature, "IE"], [:feature_version, "7"], [:paren_close, ")"], [:close, "]>"], [:open, "<!["], [:endif, "endif"], [:close, "]-->"]], tokens
  end

  def test_token_error
    assert_raises HtmlConditionalComment::TokenError do
      tokens =
        HtmlConditionalComment::Lexer.new('<!--[if IE < 5.5]--><![endif]-->').
        tokenize()
    end
  end

  def test_ignores_cdata
    tokens =
      HtmlConditionalComment::Lexer.new('<![CDATA[Comment]]>').
      tokenize()
    assert_equal [[:html, "<![CDATA[Comment]]>"]], tokens
  end
end
