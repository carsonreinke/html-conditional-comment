require 'test_helper'

class HtmlConditionalComment::ParserTest < Minitest::Test
  def test_boolean
    tokens = [[:open, "<!["], [:if, "if"], [:boolean_true, "true"], [:close, "]>"], [:html, " HTML "], [:open, "<!["], [:endif, "endif"], [:close, "]>"]]
    nodes = HtmlConditionalComment::Parser.new(tokens).parse()
    assert_equal 1, nodes.size()
    node = nodes.first
    assert_kind_of HtmlConditionalComment::Nodes::Condition, node
    assert_kind_of HtmlConditionalComment::Nodes::True, node.left
    assert_kind_of HtmlConditionalComment::Nodes::Html, node.right
    assert_equal " HTML ", node.right.string
  end

  def test_parens
    tokens = [[:open, "<!["], [:if, "if"], [:paren_open, "("], [:boolean_true, "true"], [:paren_close, ")"], [:close, "]>"], [:open, "<!["], [:endif, "endif"], [:close, "]>"]]
    nodes = HtmlConditionalComment::Parser.new(tokens).parse()
    assert_equal 1, nodes.size()
    node = nodes.first
    assert_kind_of HtmlConditionalComment::Nodes::Condition, node
    assert_kind_of HtmlConditionalComment::Nodes::True, node.left
  end

  def test_feature
    tokens = [[:open, "<!["], [:if, "if"], [:feature, "IE"], [:close, "]>"], [:open, "<!["], [:endif, "endif"], [:close, "]>"]]
    nodes = HtmlConditionalComment::Parser.new(tokens).parse()
    assert_equal 1, nodes.size()
    node = nodes.first.left
    assert_kind_of HtmlConditionalComment::Nodes::Equal, node
    assert_equal "IE", node.child.feature
  end

  def test_feature_version
    tokens = [[:open, "<!["], [:if, "if"], [:feature, "IE"], [:feature_version, "5.5"], [:close, "]>"], [:open, "<!["], [:endif, "endif"], [:close, "]>"]]
    nodes = HtmlConditionalComment::Parser.new(tokens).parse()
    node = nodes.first.left
    assert_kind_of HtmlConditionalComment::Nodes::Equal, node
    assert_equal 5.5, node.child.feature_version
  end

  def test_comparison
    tokens = [[:open, "<!["], [:if, "if"], [:operator_greater_than_equal, "gte"], [:feature, "IE"], [:feature_version, "5.5"], [:close, "]>"], [:open, "<!["], [:endif, "endif"], [:close, "]>"]]
    nodes = HtmlConditionalComment::Parser.new(tokens).parse()
    node = nodes.first.left
    assert_kind_of HtmlConditionalComment::Nodes::GreaterThanEqual, node
  end

  def test_or
    tokens = [[:open, "<!["], [:if, "if"], [:boolean_true, "true"], [:operator_or, "or"], [:boolean_false, "false"], [:close, "]>"], [:open, "<!["], [:endif, "endif"], [:close, "]>"]]
    nodes = HtmlConditionalComment::Parser.new(tokens).parse()
    node = nodes.first.left
    assert_kind_of HtmlConditionalComment::Nodes::Or, node
    assert_kind_of HtmlConditionalComment::Nodes::True, node.left
    assert_kind_of HtmlConditionalComment::Nodes::False, node.right
  end

  def test_and
    tokens = [[:open, "<!["], [:if, "if"], [:boolean_true, "true"], [:operator_and, "and"], [:boolean_false, "false"], [:close, "]>"], [:open, "<!["], [:endif, "endif"], [:close, "]>"]]
    nodes = HtmlConditionalComment::Parser.new(tokens).parse()
    node = nodes.first.left
    assert_kind_of HtmlConditionalComment::Nodes::And, node
    assert_kind_of HtmlConditionalComment::Nodes::True, node.left
    assert_kind_of HtmlConditionalComment::Nodes::False, node.right
  end

  def test_and_or
    tokens = [[:open, "<!["], [:if, "if"], [:boolean_true, "true"], [:operator_and, "and"], [:boolean_false, "false"], [:operator_or, "or"], [:boolean_true, "true"], [:close, "]>"], [:open, "<!["], [:endif, "endif"], [:close, "]>"]]
    nodes = HtmlConditionalComment::Parser.new(tokens).parse()
    node = nodes.first.left
    assert_kind_of HtmlConditionalComment::Nodes::Or, node
    assert_kind_of HtmlConditionalComment::Nodes::True, node.right

    assert_kind_of HtmlConditionalComment::Nodes::And, node.left
    assert_kind_of HtmlConditionalComment::Nodes::True, node.left.left
    assert_kind_of HtmlConditionalComment::Nodes::False, node.left.right
  end

  def test_not
    tokens = [[:open, "<!["], [:if, "if"], [:operator_not, "!"], [:boolean_true, "true"], [:close, "]>"], [:open, "<!["], [:endif, "endif"], [:close, "]>"]]
    nodes = HtmlConditionalComment::Parser.new(tokens).parse()
    node = nodes.first.left
    assert_kind_of HtmlConditionalComment::Nodes::Not, node
    assert_kind_of HtmlConditionalComment::Nodes::True, node.child
  end

  def test_syntax_error
    tokens = [[:open, "<!["], [:close, "]>"], [:open, "<!["], [:endif, "endif"], [:close, "]>"]]
    assert_raises HtmlConditionalComment::ParseError do
      HtmlConditionalComment::Parser.new(tokens).parse()
    end
  end

  def test_unbalanced_parens
    tokens = [[:open, "<!["], [:if, "if"], [:paren_open, "("], [:boolean_true, "true"], [:close, "]>"], [:open, "<!["], [:endif, "endif"], [:close, "]>"]]
    assert_raises HtmlConditionalComment::ParseError do
      HtmlConditionalComment::Parser.new(tokens).parse()
    end
  end
end
