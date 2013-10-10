module PreReviewer
  class Request
    attr_reader :account, :repo
    def initialize( args )
      if(args.size == 1)
        (@account, @repo) = args.first.split('/')
      end
    end
  end
end
