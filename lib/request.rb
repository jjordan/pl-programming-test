module PreReviewer
  ### A simple class representing the incoming request of :account and :repo.
  class Request
    attr_reader :account, :repo
    # Finds the @account and @repo from the command-line arguments.  I
    # was planning on adding more logic so that it could find them in
    # different ways, but I haven't gotten around to that yet.
    def initialize( args )
      if(args.size == 1)
        (@account, @repo) = args.first.split('/')
        # add error checking
      end
    end
  end
end
