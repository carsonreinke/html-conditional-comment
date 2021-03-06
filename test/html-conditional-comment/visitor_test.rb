require 'test_helper'

class HtmlConditionalComment::VisitorTest < Minitest::Test
  def test_to_string
    nodes = nodes(condition(
      HtmlConditionalComment::Nodes::True.instance,
      html('Works')
    ))
    visitor = HtmlConditionalComment::Visitors::ToString.new('IE', 6)
    assert_equal nodes.accept(visitor), 'Works'
  end

  def test_to_string_multiple
    nodes = nodes(
      html('1'),
      condition(
        HtmlConditionalComment::Nodes::True.instance,
        html('2')
      ),
      html('3')
    )
    visitor = HtmlConditionalComment::Visitors::ToString.new('IE', 6)
    assert_equal nodes.accept(visitor), '123'
  end

  def test_eval_boolean
    node = HtmlConditionalComment::Nodes::True.instance
    visitor = HtmlConditionalComment::Visitors::Eval.new('IE', 6)
    assert node.accept(visitor)
  end

  def test_eval_feature
    node = comparison(
      HtmlConditionalComment::Nodes::Equal,
      browser('IE')
    )
    visitor = HtmlConditionalComment::Visitors::Eval.new('IE', 6)
    assert node.accept(visitor)
  end

  def test_eval_version_vector
    node = comparison(
      HtmlConditionalComment::Nodes::Equal,
      browser('IE', HtmlConditionalComment::VersionVector.new('6'))
    )
    visitor = HtmlConditionalComment::Visitors::Eval.new('IE', 6.5)
    assert node.accept(visitor)

    visitor = HtmlConditionalComment::Visitors::Eval.new('IE', HtmlConditionalComment::VersionVector.new('6.5'))
    assert node.accept(visitor)
  end

  def test_eval_less_than
    node = comparison(
      HtmlConditionalComment::Nodes::LessThan,
      browser('IE', HtmlConditionalComment::VersionVector.new('7'))
    )
    visitor = HtmlConditionalComment::Visitors::Eval.new('IE', 6.5)
    assert node.accept(visitor)
  end

  def test_eval_less_than_equal
    node = comparison(
      HtmlConditionalComment::Nodes::LessThanEqual,
      browser('IE', HtmlConditionalComment::VersionVector.new('7'))
    )
    visitor = HtmlConditionalComment::Visitors::Eval.new('IE', 7.0)
    assert node.accept(visitor)
    visitor = HtmlConditionalComment::Visitors::Eval.new('IE', 6.0)
    assert node.accept(visitor)
  end

  def test_eval_greater_than
    node = comparison(
      HtmlConditionalComment::Nodes::GreaterThan,
      browser('IE', HtmlConditionalComment::VersionVector.new('6.5'))
    )
    visitor = HtmlConditionalComment::Visitors::Eval.new('IE', 7)
    assert node.accept(visitor)
  end

  def test_eval_greater_than_equal
    node = comparison(
      HtmlConditionalComment::Nodes::GreaterThanEqual,
      browser('IE', HtmlConditionalComment::VersionVector.new('6'))
    )
    visitor = HtmlConditionalComment::Visitors::Eval.new('IE', 6)
    assert node.accept(visitor)
    visitor = HtmlConditionalComment::Visitors::Eval.new('IE', 7)
    assert node.accept(visitor)
  end

  def test_eval_and
    node = branch(
      HtmlConditionalComment::Nodes::And,
      HtmlConditionalComment::Nodes::True.instance,
      HtmlConditionalComment::Nodes::False.instance
    )
    visitor = HtmlConditionalComment::Visitors::Eval.new('IE', 6)
    refute node.accept(visitor)
  end

  def test_eval_or
    node = branch(
      HtmlConditionalComment::Nodes::Or,
      HtmlConditionalComment::Nodes::True.instance,
      HtmlConditionalComment::Nodes::False.instance
    )
    visitor = HtmlConditionalComment::Visitors::Eval.new('IE', 6)
    assert node.accept(visitor)
  end

  def test_eval_not
    node = child(
      HtmlConditionalComment::Nodes::Not,
      HtmlConditionalComment::Nodes::False.instance
    )
    visitor = HtmlConditionalComment::Visitors::Eval.new('IE', 6)
    assert node.accept(visitor)
  end

  def test_method_missing
    nodes = nodes(condition(
      HtmlConditionalComment::Nodes::True.instance,
      html('Works')
    ))
    visitor = HtmlConditionalComment::Visitors::Visitor.new('IE', 6)
    assert_raises HtmlConditionalComment::VisitError do
      nodes.accept(visitor)
    end
  end


protected
  def child(klass, child)
    node = klass.new()
    node.child = child
    node
  end

  def branch(klass, left, right)
    node = klass.new()
    node.left = left
    node.right = right
    node
  end

  def nodes(*args)
    HtmlConditionalComment::Nodes::Nodes.new(args)
  end

  def condition(left, right)
    branch(HtmlConditionalComment::Nodes::Condition, left, right)
  end

  alias :comparison :child

  def browser(feature, version_vector = nil)
    node = HtmlConditionalComment::Nodes::Browser.new()
    node.feature = feature
    node.version_vector = version_vector
    node
  end

  def html(content)
    node = HtmlConditionalComment::Nodes::Html.new()
    node.content = content
    node
  end
end
