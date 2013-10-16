module PreReviewer
  class Criterion
    attr_reader :specifier, :field, :meaning, :match, :keyword
    def initialize( input )
      @specifier = input[:specifier]
      @field = input[:field]
      @meaning = input[:meaning]
      # change this to 'keyword' and add a 'match type', which is either: beginning, ending, contains, exact_match, and the default is exact_match
      first_boundary = last_boundary = '\b'
      if( input[:match][0] =~ /\W/ )
        first_boundary = ''
      end
      if( input[:match][-1] =~ /\W/ )
        last_boundary =  ''
      end
#      puts "boundary: #{first_boundary}"
      @keyword = input[:match]
      @match = Regexp.new(first_boundary + Regexp.escape(input[:match]) + last_boundary) # matches are escaped in a different place
      # ack, if the first character is not a word character, we can't use '\b'
      # we'd have to use \s or \W instead
      @applied = false
    end

    def apply( pull_request )
      @applied = false
      one_matched = false
      all_matched = true

      pull_request.changes.each do |change|
        if(@field == :filename)
#          puts "Checking #{@match.to_s} against filename #{change.filename}"
          if(@match.match(change.filename))
            one_matched = true 
#            puts "One matched"
          else
            all_matched = false
          end
        elsif(@field == :patch)
#          puts "Checking #{@match.to_s} against patch #{change.patch}"
          if(@match.match(change.patch))
            one_matched = true 
#            puts "One matched"
          else
            all_matched = false
          end
        end
      end
      if(@specifier == :all) && all_matched
#        puts "All matched"
        @applied = true
      end
      if(@specifier == :any) && one_matched
#        puts "One matched"
        @applied = true
      end
      if(@specifier == :none) && !one_matched
#        puts "None matched"
#        p self.inspect
        @applied = true
      end

      if(@meaning.to_sym == :interesting)
        if(@applied)
#          puts "Setting pull request to interesting"
          pull_request.is_interesting = true
        end
      elsif(@meaning.to_sym == :uninteresting)
        unless(@applied)
#          puts "Setting pull request to interesting"
          pull_request.is_interesting = true
        end
      end
    end

    def applied?
      @applied
    end
    alias_method :matched?, :applied?
  end
end
