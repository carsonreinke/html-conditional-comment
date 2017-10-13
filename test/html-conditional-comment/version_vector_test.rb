require 'test_helper'

class HtmlConditionalComment::VersionVectorTest < Minitest::Test
  def test_equal
    assert_equal HtmlConditionalComment::VersionVector.new('6'), HtmlConditionalComment::VersionVector.new('6')
    assert_equal HtmlConditionalComment::VersionVector.new('6'), HtmlConditionalComment::VersionVector.new('6.0')
    assert_equal HtmlConditionalComment::VersionVector.new('6'), HtmlConditionalComment::VersionVector.new('6.00')
    assert_equal HtmlConditionalComment::VersionVector.new('6.0'), HtmlConditionalComment::VersionVector.new('6.0')
    assert_equal HtmlConditionalComment::VersionVector.new('6.0'), HtmlConditionalComment::VersionVector.new('6.00')
    assert_equal HtmlConditionalComment::VersionVector.new('6'), HtmlConditionalComment::VersionVector.new('6.1')
  end

  def test_comparison
    assert HtmlConditionalComment::VersionVector.new('6.0') < HtmlConditionalComment::VersionVector.new('6.1')
    assert HtmlConditionalComment::VersionVector.new('10') < HtmlConditionalComment::VersionVector.new('11')
  end

  def test_nil
    assert_equal HtmlConditionalComment::VersionVector.new(nil), HtmlConditionalComment::VersionVector.new('6')
    assert_equal HtmlConditionalComment::VersionVector.new(nil), HtmlConditionalComment::VersionVector.new(nil)
  end
end
