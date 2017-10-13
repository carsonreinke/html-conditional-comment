require 'test_helper'

class HtmlConditionalCommentTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil HtmlConditionalComment::VERSION
  end

  def test_lex
    tokens = HtmlConditionalComment.lex('<!--[if true]> HTML <![endif]-->')
    assert_equal [[:open, "<!--["], [:if, "if"], [:boolean_true, "true"], [:close, "]>"], [:html, " HTML "], [:open, "<!["], [:endif, "endif"], [:close, "]-->"]],
      tokens
  end

  def test_parse
    nodes = HtmlConditionalComment.parse('<!--[if true]> HTML <![endif]-->')
    assert_kind_of HtmlConditionalComment::Nodes::Nodes, nodes
  end

  def test_to_string
    assert_equal ' HTML ', HtmlConditionalComment.to_string('<!--[if true]> HTML <![endif]-->', 'IE', '6')
  end

  def test_microsoft_ie
    html = <<-HTML
<!--[if IE]><p>You are using Internet Explorer.</p><![endif]-->
<![if !IE]><p>You are not using Internet Explorer.</p><![endif]>
    HTML
    assert_equal "<p>You are using Internet Explorer.</p>\n\n", HtmlConditionalComment.to_string(html, 'IE', '6')
    assert_equal "\n<p>You are not using Internet Explorer.</p>\n", HtmlConditionalComment.to_string(html, 'Chrome', '58')
  end

  def test_microsoft_ie_7
    html = <<-HTML
<!--[if IE 7]><p>Welcome to Internet Explorer 7!</p><![endif]-->
<!--[if !(IE 7)]><p>You are not using version 7.</p><![endif]-->
    HTML
    assert_equal "<p>Welcome to Internet Explorer 7!</p>\n\n", HtmlConditionalComment.to_string(html, 'IE', '7')
    assert_equal "\n<p>You are not using version 7.</p>\n", HtmlConditionalComment.to_string(html, 'Chrome', '58')
  end

  def test_microsoft_ie_8
    html = '<!--[if gte IE 7]><p>You are using IE 7 or greater.</p><![endif]-->'
    assert_equal '<p>You are using IE 7 or greater.</p>', HtmlConditionalComment.to_string(html, 'IE', '8')
  end

  def test_microsoft_ie_5
    html = '<!--[if (IE 5)]><p>You are using IE 5 (any version).</p><![endif]-->'
    assert_equal '<p>You are using IE 5 (any version).</p>', HtmlConditionalComment.to_string(html, 'IE', '5.0000')
  end

  def test_microsoft_ie_5_5
    html = '<!--[if (gte IE 5.5)&(lt IE 7)]><p>You are using IE 5.5 or IE 6.</p><![endif]-->'
    assert_equal '<p>You are using IE 5.5 or IE 6.</p>', HtmlConditionalComment.to_string(html, 'IE', '5.5000')
  end

  def test_microsoft_ie_3
    html = '<!--[if lt IE 5.5]><p>Please upgrade your version of Internet Explorer.</p><![endif]-->'
    assert_equal '<p>Please upgrade your version of Internet Explorer.</p>', HtmlConditionalComment.to_string(html, 'IE', '3')
  end

  def test_microsoft_ie_7_nested
    html = '<!--[if true]><![if IE 7]><p>This nested comment is displayed in IE 7.</p><![endif]><![endif]-->'
    assert_equal '<p>This nested comment is displayed in IE 7.</p>', HtmlConditionalComment.to_string(html, 'IE', '7')
  end
end
