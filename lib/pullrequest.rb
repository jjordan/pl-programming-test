require 'config'
require 'change'
require 'json'
require 'fetcher'

module PreReviewer
  class PullRequest 
    attr_reader :account, :name, :number

    def initialize( request, input )
      @config = PreReviewer::Config.instance
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
        fetcher = PreReviewer::Fetcher.new
        api_url = @config.change_api( @account, @name, @number )
        changes = fetcher.fetch( api_url )
        changes.each do |change|
          @changes << PreReviewer::Change.new( change )
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
