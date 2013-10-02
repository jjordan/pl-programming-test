module PreReviewer
  class Change
    def self.new_from_hash( input )
      self.new( input )
    end

    attr_reader :filename, :status, :patch

    def initialize( input )
      @filename = input['filename']
      @status = input['status']
      @patch = input['patch']
    end

  end # end class
end # end module
