require 'fetcher'
require 'config'
require 'pullrequest'

module PreReviewer
  class Repository
    attr_reader :name, :account, :selected_pulls, :config
    attr_accessor :pull_state
    def initialize( request )
      @request = request
      @account = request.account
      @name = request.repo
      @pull_state = 'open'
      @pulls = []
      @config = PreReviewer::Config.instance
    end

    def pulls
      fetcher = PreReviewer::Fetcher.new
      api_url = @config.pull_api( @account, @name )
      pulls = fetcher.fetch( api_url )
#      p pulls
      pulls.each do |pull|
        @pulls << PreReviewer::PullRequest.new( @request, pull )
      end
      # check for no pulls
      # check for no pulls of 'type'
      if(@pull_state)
        @selected_pulls = @pulls.select {|p| p.state == @pull_state}
      else
        @pulls
      end
    end
  end

end
