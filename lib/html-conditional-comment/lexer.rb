require 'strscan'

module HtmlConditionalComment
  class TokenError < StandardError
    def initialize(rest)
      super("Invalid token \"#{rest.to_s.slice(0, 25)}\"")
    end
  end

  ##
  # Converts string into array of tokens.  Token is an array, first element is
  # symbol representing the token, second element is string value.
  #
  class Lexer
    LESS_THAN = /lt/i
    LESS_THAN_EQUAL = /lte/i
    GREATER_THAN = /gt/i
    GREATER_THAN_EQUAL = /gte/i
    OPEN_PAREN = /\(/
    CLOSE_PAREN = /\)/
    NOT = /\!/
    OR = /\|/
    AND = /\&/
    TRUE = /true/i
    FALSE = /false/i
    IF_STATEMENT = /if/i
    ENDIF_STATEMENT = /endif/i
    #Opening statement plus positive look ahead to avoid conflicts with other
    #comments, could also have additional comments before "if"
    OPEN = /<!(\-\-)?[^>]*?\[(?=(end)?if)/
    #Closing statement with additional comments after "endif"
    CLOSE = /\].*?(\-\-)?>/
    WHITE_SPACE = /\s+/
    FEATURE = /[a-z]+/i
    VERSION_VECTOR = /\d+(\.[\d]+)?/

    TOKENS = [
      [:if, IF_STATEMENT],
      [:endif, ENDIF_STATEMENT],

      [:paren_open, OPEN_PAREN],
      [:paren_close, CLOSE_PAREN],

      [:operator_less_than_equal, LESS_THAN_EQUAL],
      [:operator_less_than, LESS_THAN],
      [:operator_greater_than_equal, GREATER_THAN_EQUAL],
      [:operator_greater_than, GREATER_THAN],

      [:operator_not, NOT],
      [:operator_or, OR],
      [:operator_and, AND],

      [:boolean_true, TRUE],
      [:boolean_false, FALSE],
      [:feature, FEATURE],
      [:version_vector, VERSION_VECTOR]
    ]

    def initialize(html_or_comment)
      @scanner = StringScanner.new(html_or_comment)
    end

    def tokenize()
      tokens = []
      open = false

      #Run until nothing left in string
      until @scanner.eos?()
        #Split between if the conditional comment has been opened or not
        #State will help handle all the other HTML we don't care about
        if open
          @scanner.skip(WHITE_SPACE)
          if token = @scanner.scan(CLOSE)
            open = false
            tokens << [:close, token]
          else
            #Go through token specs and scan and stop on first one
            token = TOKENS.inject(nil) do |previous, spec|
              t = @scanner.scan(spec[1])
              unless t.nil?()
                break [spec[0], t]
              end
            end
            if token
              tokens << token
            else
              raise TokenError.new(@scanner.rest())
            end
          end
        #Closed (not opened) conditional comment
        else
          #Scan till we find an open token, if not done and use the rest
          if match = @scanner.scan_until(OPEN)
            open = true
            #TODO Gross way to get up till scan has succeeded
            match = match.slice(0..-(@scanner.matched.size() + 1))
            tokens << [:html, match] unless match.empty?()
            tokens << [:open, @scanner.matched]
          else
            tokens << [:html, @scanner.rest()] if @scanner.rest?()
            break
          end
        end
      end
      @scanner.reset()

      tokens
    end

  end
end
