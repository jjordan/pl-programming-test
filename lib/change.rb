module PreReviewer
  class Change
    attr_reader :filename, :status, :patch

    def initialize( input )
      @filename = input['filename']
      @status = input['status']
      @patch = input['patch']
    end

    def render(criteria)
      if criteria.specifier != :none 
        if(criteria.meaning == :interesting )
          if(criteria.field == :patch )
            if(criteria.match.match( @patch ))
              return "matched: %s" % [ @patch ]
            end
          elsif(criteria.field == :filename)
            if(criteria.match.match( @filename ))
              return "matched: %s" % [ @filename ]
            end              
          end
        end
      end
      return nil
    end

  end # end class
end # end module
