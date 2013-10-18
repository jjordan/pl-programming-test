module PreReviewer
  ### A simple class representing the incoming request of :account and :repo.
  class Request
    # The account of the request
    attr_reader :account
    # The repository name of the request.
    attr_reader :repo
    # Finds the account and repo from the command-line +args+.  I
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
