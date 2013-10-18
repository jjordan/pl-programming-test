module PreReviewer
  ### The Change class represents a single modification in a PullRequest.
  class Change
    attr_reader :filename, :status, :patch

    # sets the @filename, @status and @patch from the input hash
    def initialize( input )
      raise "input #{input.inspect} is not a hash" unless(input.is_a?( Hash ) )
      @filename = input['filename']
      @status = input['status']
      @patch = input['patch']
    end

    # Returns a string describing how the change matched a given
    # Criteria, or nil if there was no match.
    def render(criteria)
      if criteria.specifier == :any
        if(criteria.meaning == :interesting )
          if(criteria.field == :patch )
            if(criteria.match.match( @patch ))
              return "\tfound '%s' in patch" % [ criteria.match.to_s ]
            end
          elsif(criteria.field == :filename)
            if(criteria.match.match( @filename ))
              return "\tfound '%s' in %s" % [ criteria.match.to_s, @filename ]
            end              
          end
        end
      end
      return nil
    end

  end # end class
end # end module
