require 'configurability'

module PreReviewer
  class Repository
    extend Configurability
    attr_reader :name, :account, :pulls, :selected_pulls
    attr_accessor :pull_state, :config
    def initialize( request )
      @account = request.account
      @name = request.repo
      @pull_state = 'open'
      @pulls = []
    end

    def pulls
      fetcher = @config.fetcher
      api_url = @config.pull_api( @account, @name )
      pulls = fetcher.get( api_url )
      pulls.each do |pull|
        @pulls << PreReviewer::PullRequest.new_from_hash( pull )
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
