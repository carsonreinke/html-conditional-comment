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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/carsonreinke/html-conditional-comment.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
