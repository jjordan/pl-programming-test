require 'config'
require 'httparty'

module PreReviewer
  ### A simple extraction around the HTTP method so that I can change
  ### this later without breaking too many tests or other parts of the
  ### system.
  class Fetcher
    # Returns the config file
    attr_accessor :config

    # Loads the singleton config
    def initialize
      @config = PreReviewer::Config.instance
    end

    # Given a +URL+ for a GitHub API, this returns any data that is
    # JSON.  Probably needs a crapload more error checking.
    def fetch( url )
      url = add_extra_params( url )
      #p url
      response = HTTParty.get( url )
      j_response = JSON.parse( response.body )
      return j_response
    end

    protected

    # A deprecated method to add additional parameters to a given +URL+.
    # I realized that I liked this functionality in the Config object
    # better, since the 'access token', which is the most commone
    # extra parameter also lives there, and it makes calling the
    # fetcher simpler.
    def add_extra_params( url )
      if(@config.extra_params)
        query = []
        @config.extra_params.each_pair do |k,v|
          query << [k,v].join("=")
        end
        qs = query.join("&")
        if( url =~ /\?/ )
          url += "&" + qs
        else
          url += "?" + qs
        end
      end
      return url
    end

  end
end
