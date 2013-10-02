module PreReviewer
  class Criteria
    attr_reader :specifier, :field, :meaning, :match
    def initialize( input )
      @specifier = input[:specifier]
      @field = input[:field]
      @meaning = input[:meaning]
      @match = Regexp.new(input[:match]) # matches are escaped in a different place
      @applied = false
    end

    def apply( pull_request )
      one_matched = false
      all_matched = true

      pull_request.changes.each do |change|
        if(@field == :filename)
          if(@match.match(change.filename))
            one_matched = true 
          else
            all_matched = false
          end
        elsif(@field == :patch)
          if(@match.match(change.patch))
            one_matched = true 
          else
            all_matched = false
          end
        end
      end
      if(@specifier == :all) && all_matched
        @applied = true
      end
      if(@specifier == :any) && one_matched
        @applied = true
      end
      if(@specifier == :none) && !one_matched
        @applied = true
      end
    end

    def applied?
      @applied
    end
    alias_method :matched?, :applied?
  end
end
