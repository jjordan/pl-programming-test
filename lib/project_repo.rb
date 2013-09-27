module PreReviewer
  class ProjectRepo
    attr_reader :name, :account, :pulls, :selected_pulls
    attr_accessor :pull_state
    API_ROOT = 'https://api.github.com/repos/'
    def initialize( config, account_repo )
      (@account, @name) = account_repo.split('/')
      @pull_state = 'open'
      @config = config
    end

    def fetch_pulls
      api_url = API_ROOT + "%s/%s/pulls" % [@account, @name]
      fetcher = @config.fetcher
      pulls = fetcher.get( api_url )
      @pulls = pulls
      # check for no pulls
      # check for no pulls of 'type'
      if(@pull_state)
        @selected_pulls = @pulls.select {|p| p["state"] == @pull_state}
      else
        @pulls
      end
    end
  end


end
