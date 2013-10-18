require 'fetcher'
require 'config'
require 'pullrequest'

module PreReviewer
  ### The class representing the GitHub repository to check the pull
  ### requests of.  It knows it's name, account and can find it's
  ### config.  It also can find selected_pulls given a pull_state,
  ### which defaults to 'open'.
  class Repository
    # The name of the repository
    attr_reader :name
    # The account for this repository
    attr_reader :account
    # The pulls that matched the 'pull state'
    attr_reader :selected_pulls
    # The config object
    attr_reader :config
    # The pull state, whether 'open', 'closed' or whatevs.
    attr_accessor :pull_state

    # Uses the +request+ and Singleton Config to find the repository
    # information.
    def initialize( request )
      @request = request
      @account = request.account
      @name = request.repo
      @pull_state = 'open'
      @pulls = []
      @config = PreReviewer::Config.instance
      @selected_pulls = []
    end

    # Fetches (and caches) Pull Requests for this repository.  Matches
    # them against the @pull_state to determine which ones are needed.
    def pulls
      return @selected_pulls unless( @selected_pulls.empty? )
      fetcher = PreReviewer::Fetcher.new
      api_url = @config.pull_api( @account, @name )
      pulls = fetcher.fetch( api_url )
#      p pulls
      pulls.each do |pull|
        @pulls << PreReviewer::PullRequest.new( @request, pull )
      end
      # check for no pulls
      # check for no pulls of 'type'
      @selected_pulls = []

      if(@pull_state)
        @selected_pulls = @pulls.select {|p| p.state == @pull_state}
      else
        @selected_pulls = @pulls
      end
      return @selected_pulls
    end
  end

end
