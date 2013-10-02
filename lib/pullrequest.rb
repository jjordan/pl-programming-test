require 'json'

module PreReviewer
  class PullRequest 
    attr_reader :account, :name, :number
    def self.new_from_hash(config, request, input )
      self.new( config, request, input )
    end

    def initialize( config, request, input )
      @config = config
      @request = request
      @account = request.account
      @name = request.name
      @number = input["number"]
      @interesting = true
      @changes = []
    end

    def is_interesting?
      @interesting
    end

    def is_interesting=( interesting )
      @interesting = interesting
    end

    def changes
      if(@changes.empty?)
        fetcher = @config.fetcher
        api_url = @config.change_api( @account, @name, @number )
        changes = fetcher.get( api_url )
        changes.each do |change|
          @changes << PreReviewer::Change.new_from_hash( change )
        end
      end
      @changes
    end

    def render
      status = @interesting ? 'Interesting' : 'Not Interesting'
      root = @config.html_root # should pass @account and @name in here, no?
      "#{root}/#{@account}/#{@name}/pull/#{@number} - #{status}"
    end

  end
end
