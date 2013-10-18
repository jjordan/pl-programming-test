require 'config'
require 'change'
require 'json'
require 'fetcher'

module PreReviewer
  ### The class representing a single pull request from another GitHub
  ### user.  It knows it's :account, :name, :pull_number and :state
  ### (e.g., 'open', 'closed', etc.)
  class PullRequest 
    # The account of the repository
    attr_reader :account
    # The name of the repository
    attr_reader :name
    # The number of this pull request
    attr_reader :number 
    # The state of this pull request, e.g., 'open', 'closed'
    attr_reader :state

    # Uses the +request+, +input+ and config to initialize itself.
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

    # Returns whether this pull request has been found to be
    # interesting (true) or uninteresting (false).
    def is_interesting?
      @interesting
    end

    # Used by other classes (Criterion) to set whether this pull
    # request is interesting.  Could use some error checking :/
    def is_interesting=( interesting )
      @interesting = interesting
    end

    # Fetches (and caches) the changes for this pull request using the
    # 'fetcher' class, and returns them.
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

    # Returns a string describing whether this specific pull request
    # was interesting or uninteresting, along wiht the HTML URL for
    # the pull.
    def render
      status = @interesting ? 'Interesting' : 'Not Interesting'
      root = @config.html_root # should pass @account and @name in here, no?
      "#{root}/#{@account}/#{@name}/pull/#{@number} - #{status}"
    end

    # Given a +criterion+, returns why this pull request was considered
    # interesting, based on how the Criterion matched it.
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
