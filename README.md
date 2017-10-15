# HTML Conditional Comment Evaluater, Parser, and Lexer

Evaluate, parse, and tokenizing HTML conditional comments using provided features and version.  Allows for existing HTML to be maintained and only conditional comments to evaluated.

## Why?

Conditional comments are really a legacy approach, however the application is still quite prevelant in the email marketing industry.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'html-conditional-comment'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install html-conditional-comment

## Usage

* Evaluating:
`HtmlConditionalComment.to_string("What is the <!--[if gte mso 9]>Outlook<![endif]-->?", "mso", 9) => "What is the Outlook?"`

* Parsing: `HtmlConditionalComment.parse(...) => HtmlConditionalComment::Nodes::Nodes`

* Tokenizing: `HtmlConditionalComment.lex(...) => [[:open, "<!--["], [:if, "if"]...`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/carsonreinke/html-conditional-comment.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
