module HtmlConditionalComment
  class VersionVector
    include Comparable

    DOT = /\./
    DIGIT = /\d/

    attr_accessor :string

    def initialize(string)
      @string = nil
      @string = string.to_s() unless string.nil?()
    end

    def <=>(other)
      #Force comparison class
      other = VersionVector.new(other) unless other.is_a?(VersionVector)

      return 0 if @string.nil?() || other.string.nil?()
      return 0 if @string == other.string

      #Normalize version array sizes
      left, right = self.to_a(), other.to_a()
      size = [left.size(), right.size()].min()
      left.slice!(size..-1)
      right.slice!(size..-1)

      #Compare based on number
      left.join.to_f() <=> right.join.to_f()
    end

    ##
    # Split string into array of version numbers, major can be multiple digits,
    # minor can only be a single digit
    #
    def to_a()
      major, minors = @string.split(DOT)
      versions = (minors || '').scan(DIGIT)
      versions.unshift(major, '.')
      versions
    end
  end
end
