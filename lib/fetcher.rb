require 'config'
require 'httparty'

module PreReviewer
  class Fetcher
    attr_accessor :config
    def initialize
      @config = PreReviewer::Config.instance
    end

    def fetch( url )
      url = add_extra_params( url )
      #p url
      response = HTTParty.get( url )
      j_response = JSON.parse( response.body )
      return j_response
    end

    protected

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
