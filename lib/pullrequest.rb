require 'config'
require 'change'
require 'json'
require 'fetcher'

module PreReviewer
  class PullRequest 
    attr_reader :account, :name, :number, :state

    def initialize( request, input )
      @config = PreReviewer::Config.instance
      @request = request
      @account = request.account
      @name = request.repo
      @number = input["number"]
      @state = input["state"]
      @interesting = false
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
#          p change.inspect
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

    def render_reason( criterion )
      if @interesting
        if criterion.specifier == :none
          if criterion.field == :filename
            return "\tno file names contained '%s'" % [criterion.match.to_s]
          end
          if criterion.field == :patch
            return "\tno patches contained '%s'" % [criterion.match.to_s]
          end
        elsif criterion.specifier == :all
          if criterion.field == :filename
            return "\tall file names contained '%s'" % [criterion.match.to_s]
          end
          if criterion.field == :patch
            return "\tall patches contained '%s'" % [criterion.match.to_s]
          end
        end
      end
    end

  end
end
