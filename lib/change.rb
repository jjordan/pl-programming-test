module PreReviewer
  class Change
    attr_reader :filename, :status, :patch

    def initialize( input )
      @filename = input['filename']
      @status = input['status']
      @patch = input['patch']
    end

    def render(criteria)
      if(criteria.component == :change )
        if criteria.specifier != :none 
          if(criteria.meaning == :interesting )
            if(criteria.field == :patch )
              if(criteria.regexp.match( @patch ))
                return "matched: %s" % [ @patch ]
              end
            elsif(criteria.field == :filename)
              if(criteria.regexp.match( @filename ))
                return "matched: %s" % [ @filename ]
              end              
            end
          end
        end
      end
    end

  end # end class
end # end module
